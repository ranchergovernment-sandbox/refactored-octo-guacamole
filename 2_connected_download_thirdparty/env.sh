#!/bin/bash

platform=linux/amd64


function sync_product {
	mkdir -p artifacts/${1}
	pushd artifacts/${1}
	hauler store sync --platform ${platform} --products ${1}=${2} --product-registry registry.ranchercarbide.dev
	popd

}