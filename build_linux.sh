#!/usr/bin/env bash
set -e
cd $(dirname "$0")

if [ "$(uname)" == "Darwin" ]; then
	export GOOS="${GOOS:-linux}"
fi

ORG_PATH="github.com/containernetworking"
export REPO_PATH="${ORG_PATH}/plugins"

if [ ! -h gopath/src/${REPO_PATH} ]; then
	mkdir -p gopath/src/${ORG_PATH}
	ln -s ../../../.. gopath/src/${REPO_PATH} || exit 255
fi

export GOPATH=${PWD}/gopath
export GO="${GO:-go}"

mkdir -p "${PWD}/bin"

echo "Building plugins ${GOOS}"
# PLUGINS="plugins/meta/* plugins/main/* plugins/ipam/* plugins/sample"
PLUGINS="plugins/main/antibridge"
for d in $PLUGINS; do
	if [ -d "$d" ]; then
		plugin="$(basename "$d")"
		if [ $plugin != "windows" ]; then
			echo "  $plugin"
			$GO build -o "${PWD}/bin/$plugin" "$@" "$REPO_PATH"/$d
		fi
	fi
done

# gcloud compute scp --zone=us-west1-a bin/antibridge antidote-worker-6l0v:/tmp
# gcloud compute scp --zone=us-west1-b bin/antibridge antidote-worker-2nqc:/tmp
# gcloud compute scp --zone=us-west1-c bin/antibridge antidote-worker-z54h:/tmp

# gcloud compute ssh --zone=us-west1-a antidote-worker-6l0v --command="sudo mv /tmp/antibridge /opt/cni/bin/antibridge"
# gcloud compute ssh --zone=us-west1-b antidote-worker-2nqc --command="sudo mv /tmp/antibridge /opt/cni/bin/antibridge"
# gcloud compute ssh --zone=us-west1-c antidote-worker-z54h --command="sudo mv /tmp/antibridge /opt/cni/bin/antibridge"

# gcloud compute ssh --zone=us-west1-a antidote-worker-6l0v --command="sudo systemctl restart kubelet"
# gcloud compute ssh --zone=us-west1-b antidote-worker-2nqc --command="sudo systemctl restart kubelet"
# gcloud compute ssh --zone=us-west1-c antidote-worker-z54h --command="sudo systemctl restart kubelet"
