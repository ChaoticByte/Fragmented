set -e

function log {
    echo -e "\033[1;36m***** $@ *****\033[0m"
}

mkdir -p dist

log Building application

VERSION="$(godot --headless --no-header -s tools/get_version.gd)"

godot --headless --export-release "Linux/X11" "dist/Fragmented-${VERSION}.x86_64"

log Packing shaderlib

ZIP_PATH_SHADERLIB=$(realpath "dist/Fragmented-${VERSION}_shaderlib.zip")

zip -r "${ZIP_PATH_SHADERLIB}" shaderlib/

log Packing project template

ZIP_PATH_PROJECT_TEMPLATE=$(realpath "dist/Fragmented-${VERSION}_project_template.zip")

rm -f "${ZIP_PATH_PROJECT_TEMPLATE}"
(
    cd examples/
    mv project.godot_ project.godot && trap "mv project.godot project.godot_" EXIT
    zip -r "${ZIP_PATH_PROJECT_TEMPLATE}" *
)
