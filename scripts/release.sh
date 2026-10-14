#!/usr/bin/env bash
# Builds the MADS CLI release zip from the private madsv5/mads-cli repo and points the
# Homebrew formula and the Scoop manifest at it.
#
#   scripts/release.sh [--publish] [MADS_CLI_REPO] [REF]
#
# Without --publish it only builds dist/mads-<version>.zip and rewrites
# Formula/mads.rb and bucket/mads.json. With --publish it also commits, tags,
# pushes this repo and creates the GitHub release with the zip and version.txt,
# which `mads` reads to detect new versions (needs `gh auth login`). The release
# notes are the CHANGELOG.md section of the version.
set -euo pipefail

PUBLISH=0
if [[ "${1:-}" == "--publish" ]]; then PUBLISH=1; shift; fi

TAP_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
SRC="${1:-$TAP_DIR/../mads-cli}"
REF="${2:-HEAD}"
REPO_SLUG="sivicomeng/homebrew-mads"

# Always read from git, never from the working tree.
VERSION_TXT="$(git -C "$SRC" show "$REF:bin/internal/version.txt")"
VERSION="$(sed -n 's/^version=//p' <<<"$VERSION_TXT" | tr -d '\r' | tr '_' '-')"
[[ -n "$VERSION" ]] || { echo "No version= in $REF:bin/internal/version.txt" >&2; exit 1; }

TAG="v$VERSION"
ZIP="$TAP_DIR/dist/mads-$VERSION.zip"
URL="https://github.com/$REPO_SLUG/releases/download/$TAG/mads-$VERSION.zip"

if (( PUBLISH )) && [[ -n "$(git -C "$TAP_DIR" ls-remote --tags origin "refs/tags/$TAG")" ]]; then
  echo "$TAG is already released" >&2; exit 1
fi

mkdir -p "$TAP_DIR/dist"
printf 'version=%s\n' "$(tr '-' '_' <<<"$VERSION")" > "$TAP_DIR/dist/version.txt"
git -C "$SRC" show "$REF:CHANGELOG.md" \
  | awk -v h="## $VERSION" '$0 == h {on = 1; next} on && /^## / {exit} on' > "$TAP_DIR/dist/notes.md"
[[ -s "$TAP_DIR/dist/notes.md" ]] || echo "MADS V5 CLI $VERSION" > "$TAP_DIR/dist/notes.md"
git -C "$SRC" archive --format=zip --prefix="mads-$VERSION/" -o "$ZIP" "$REF" \
  bin LICENSE README.md CHANGELOG.md AUTHORS
SHA="$(shasum -a 256 "$ZIP" | cut -d' ' -f1)"

perl -pi -e "
  s|^(\s*url \").*(\")|\${1}$URL\${2}|;
  s|^(\s*version \").*(\")|\${1}$VERSION\${2}|;
  s|^(\s*sha256 \").*(\")|\${1}$SHA\${2}|;
" "$TAP_DIR/Formula/mads.rb"

# Only the top-level fields; the "autoupdate" block keeps its $version templates.
perl -pi -e "
  \$auto = 1 if /\"autoupdate\"/;
  next if \$auto;
  s|^(\s*\"version\": \").*(\")|\${1}$VERSION\${2}|;
  s|^(\s*\"url\": \").*(\")|\${1}$URL\${2}|;
  s|^(\s*\"hash\": \").*(\")|\${1}$SHA\${2}|;
  s|^(\s*\"extract_dir\": \").*(\")|\${1}mads-$VERSION\${2}|;
" "$TAP_DIR/bucket/mads.json"

echo "version: $VERSION"
echo "zip:     $ZIP ($(du -h "$ZIP" | cut -f1))"
echo "sha256:  $SHA"

if (( PUBLISH )); then
  git -C "$TAP_DIR" add Formula/mads.rb bucket/mads.json
  git -C "$TAP_DIR" diff --cached --quiet || git -C "$TAP_DIR" commit -m "mads $VERSION"
  git -C "$TAP_DIR" tag -a "$TAG" -m "MADS $VERSION"
  git -C "$TAP_DIR" push origin HEAD "$TAG"
  gh release create "$TAG" "$ZIP" "$TAP_DIR/dist/version.txt" --repo "$REPO_SLUG" \
    --title "MADS $VERSION" --notes-file "$TAP_DIR/dist/notes.md" --latest
fi
