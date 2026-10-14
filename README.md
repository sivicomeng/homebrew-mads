# MADS V5 CLI — Homebrew tap & Scoop bucket

Paquetes de instalación de la herramienta de línea de comandos MADS V5.
Requiere un JDK 8 o superior.

## macOS / Linux (Homebrew)

```bash
brew tap sivicomeng/mads
brew install mads
mads --version
```

Actualizar: `brew upgrade mads`

## Windows (Scoop)

```powershell
scoop bucket add java                       # solo si no tienes un JDK
scoop install java/temurin-lts-jdk          # solo si no tienes un JDK
scoop bucket add mads https://github.com/sivicomeng/homebrew-mads
scoop install mads/mads
mads --version
```

Actualizar: `scoop update mads`

## Publicar una versión nueva

Se hace desde el repo privado `madsv5-platform` con `mads-tool/scripts/deploy.sh`,
que compila la herramienta, la sube a `madsv5/mads-cli` y llama a
`scripts/release.sh --publish` de este repo. Ese script genera el zip desde git,
actualiza la fórmula y el manifiesto, y crea la release con el zip, `version.txt`
(que `mads` consulta para avisar de versiones nuevas) y las notas del CHANGELOG.
