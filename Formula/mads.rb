# MADS V5 CLI Tool Homebrew Formula
# url/version/sha256 are updated by scripts/release.sh — do not edit by hand.
class Mads < Formula
  desc "MADS V5 Command Line Tool for building modular applications"
  homepage "https://mads.sivicom.cat/"
  url "https://github.com/sivicomeng/homebrew-mads/releases/download/v5.1.0-b20261006/mads-5.1.0-b20261006.zip"
  version "5.1.0-b20261006"
  sha256 "2b40e4c4aa21bbf664787eb7c29341db6e73bdbbfb28c7e248056360b427f12c"
  license "BSD-3-Clause"

  # The jars target Java 8 bytecode, so any current JDK runs them.
  depends_on "openjdk"

  def install
    libexec.install "bin"
    (bin/"mads").write_env_script libexec/"bin/mads",
      JAVA_HOME_MADS: Formula["openjdk"].opt_prefix
  end

  test do
    assert_match "MADS V5 tool version", shell_output("#{bin}/mads --version")
  end
end
