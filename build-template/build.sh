#!/usr/bin/env bash

set -e

function log {
    echo -e "\033[1;36m***** $@ *****\033[0m"
}

log "                                         "
log "Fragmented - Godot Build Template Builder"
log "                                         "

cd $(dirname $0)
log Switched to $(pwd)

tmpsuffix=$(date +%s%N)
image_name=fragmented-godot-template-builder
container_name=${image_name}-${tmpsuffix}
output_file=godot.linuxbsd.template_release.x86_64

log Building image ${image_name} ...
buildah build -t ${image_name}
log Building godot build template with container ${container_name} ...
podman run --name ${container_name} localhost/${image_name}:latest
log Copying ${output_file} from container to $(realpath ./${output_file})
podman cp ${container_name}:/godot-src/bin/${output_file} ./${output_file}
log Removing container ${container_name}
podman container rm ${container_name}
log Done :D
