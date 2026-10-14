# MADS V5 CLI — Homebrew tap & Scoop bucket

Paquetes de instalación de la herramienta de línea de comandos MADS V5.
Requiere un JDK 8 o superior.

## macOS / Linux (Homebrew)

```bash
brew tap sivicom/mads
brew install mads
mads --version
```

Actualizar: `brew upgrade mads`

## Windows (Scoop)

```powershell
scoop bucket add java                       # solo si no tienes un JDK
scoop install java/temurin-lts-jdk          # solo si no tienes un JDK
scoop bucket add mads https://github.com/sivicom/homebrew-mads
scoop install mads/mads
mads --version
```

Actualizar: `scoop update mads`

## Publicar una versión nueva

Desde este repo, con el repo privado `madsv5` clonado en `../mads-cli/madsv5`
y `gh auth login` hecho:

```bash
scripts/release.sh             # genera dist/mads-<versión>.zip y actualiza fórmula y manifiesto
scripts/release.sh --publish   # además hace commit, tag, push y sube el zip como GitHub Release
```

La versión se lee de `bin/internal/version.txt` del commit indicado
(`scripts/release.sh [--publish] [RUTA_MADSV5] [REF]`).
