#!/usr/bin/env bash
set -euxo pipefail

# Copy build scripts into a directory within the container. Avoids polluting the mounted
# directory and permission errors.
mkdir /home/builder/workspace
cp -R /home/builder/build/generated/packaging /home/builder/workspace


# $ and $ARCH are env variables passing in from "docker run"
debVersionList="stretch buster bullseye bionic focal groovy hirsute jammy"
dpkgExtraARG="-us -uc" 

echo "DEBUG: building DEbian arch ${buildArch}"
if [[ "${buildArch}" == "all" ]]; then
	dpkgExtraARG="${dpkgExtraARG} -b" # equal to --build=any,all
else
    dpkgExtraARG="${dpkgExtraARG} --build=${buildArch}"
fi

# Build package and set distributions it supports
cd /home/builder/workspace/packaging
dpkg-buildpackage ${dpkgExtraARG}
changestool /home/builder/workspace/*.changes setdistribution ${debVersionList}

# Copy resulting files into mounted directory where artifacts should be placed.
mv /home/builder/workspace/*.{deb,changes,buildinfo} /home/builder/out
