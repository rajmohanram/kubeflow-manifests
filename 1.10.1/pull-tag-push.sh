#!/bin/bash

set -euo pipefail

INPUT_FILE="images.txt"
PARALLEL_JOBS=8

# Function to pull, tag, and push an image
pull_tag_push() {
    src_image="$1"
    dst_image="$2"

    echo "DEBUG: src_image='$src_image', dst_image='$dst_image'"

    echo ">>> Processing: $src_image -> $dst_image"

    if [[ -z "$src_image" || -z "$dst_image" ]]; then
        echo "!!! Source or destination image is missing" >&2
        exit 1
    fi

    echo ">>> Pulling: $src_image"
    if ! docker pull "$src_image"; then
        echo "!!! Failed to pull $src_image" >&2
        exit 1
    fi

    echo ">>> Tagging: $src_image -> $dst_image"
    docker tag "$src_image" "$dst_image"

    echo ">>> Pushing: $dst_image"
    if ! docker push "$dst_image"; then
        echo "!!! Failed to push $dst_image" >&2
        exit 1
    fi
}

export -f pull_tag_push

# Read and process the file in parallel
# cat "$INPUT_FILE" | parallel -j "$PARALLEL_JOBS" --colsep ' ' pull_tag_push {1} {2}
awk 'NF == 2' "$INPUT_FILE" | parallel -j "$PARALLEL_JOBS" --colsep '\s+' pull_tag_push {1} {2}
