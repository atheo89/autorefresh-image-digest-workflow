#!/bin/bash   
HASH_N=f8af4e2 
RELEASE_VERSION_N=2024a

path=jupyter/datascience/ubi9-python-3.9/runtime-images/rocm-tensorflow-ubi9-py39.json
img=quay.io/opendatahub/workbench-images@sha256:a1bbf6153921b60cb58f094d110bf6dc054d13a07c4c513a6b994d1b74a8b60e
name=$(echo "$path" | sed 's#.*runtime-images/\(.*\)-py.*#\1#')
py_version=$(echo "$path" | grep -o 'python-[0-9]\.[0-9]')
# Handling specific cases
if [[ $name == tensorflow* ]]; then
    name="cuda-$name"
elif [[ $name == ubi* ]]; then
    name="minimal-$name"
fi
registry=$(echo $img | cut -d '@' -f1)
echo "DEBUG registry: "  $registry
regex="^runtime-$name-$py_version-$RELEASE_VERSION_N-\d+-$HASH_N\$"
echo "CHECKING: "  $regex
latest_tag=$(skopeo inspect docker://$img | jq -r --arg regex "$regex" '.RepoTags | map(select(. | test($regex))) | .[0]')
echo "DEBUG latest_tag: "  $latest_tag

digest=$(skopeo inspect docker://$registry:$latest_tag | jq .Digest | tr -d '"')
echo "DEBUG digest: "  $digest

echo "NEW: " $output
