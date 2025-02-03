set -e

function log {
    echo -e "\033[1;36m***** $@ *****\033[0m"
}

log Building application

VERSION="$(godot --headless --no-header -s tools/get_version.gd)"

godot --headless --export-release "Linux/X11" "dist/Fragmented-${VERSION}.x86_64"

log Packing project template

ZIP_PATH=$(realpath "dist/Fragmented-${VERSION}_project_template.zip")

rm -f "${ZIP_PATH}"
zip -r "${ZIP_PATH}" shaderlib/
(
    cd examples/
    zip -r "${ZIP_PATH}" *
)
