#!/bin/bash

HASH_N=6f4c36b
RELEASE_VERSION_N_1=2024a
IMAGES=odh-minimal-gpu-notebook-image-n-1
REGEXES="cuda-[a-z]+-minimal-[a-z0-9]+-[a-z]+-3.8-${RELEASE_VERSION_N_1}-[0-9]{8}-${HASH_N}" # Updated regex to use [0-9] instead of \d for better compatibility
image=${IMAGES}
regex=${REGEXES}
echo "Regex: " $regex

img=$(cat params.env | grep -E "${image}=" | cut -d '=' -f2)
if [ -z "$img" ]; then
    echo "Error: Image not found in params.env"
    exit 1
fi
echo "Selected Image from params.env: " $img

registry=$(echo $img | cut -d '@' -f1)
echo "Image's Registry: " $registry

latest_tag=$(skopeo inspect docker://$img | jq -r --arg regex "$regex" '.RepoTags | map(select(. | test($regex))) | .[0]')
if [ -z "$latest_tag" ]; then
    echo "Error: No tag found matching the regex pattern"
    exit 1
fi
echo "Latest tag: " $latest_tag

digest=$(skopeo inspect docker://$registry:$latest_tag | jq .Digest | tr -d '"')
echo "Digest : " $digest

output=$registry@$digest
echo "Latest notebook" $output
