#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=${1:?Usage: build-mu.sh NEW_BUILD_DIRECTORY}
test ! -e "$work" || { echo 'Choose a new build directory' >&2; exit 1; }
git clone --branch v4.1 --single-branch https://github.com/Project-Silicium/Mu-Silicium.git "$work"
cd "$work"
test "$(git rev-parse HEAD)" = 6b3d90b79e191e08171bfedd3980234a7e49d340
git apply --check "$repo/patches/mu-v4.1-m2381-adaptation.patch"
git apply "$repo/patches/mu-v4.1-m2381-adaptation.patch"
git submodule sync
git submodule update --init --jobs 4 Binaries Common/Mu Common/Mu_OEM_Sample Mu_Basecore Silicium-ACPI Silicon/Silicium/OpensslPkg/Library/OpensslLib/openssl
test "$(git -C Binaries rev-parse HEAD)" = 036ba9f7cfe2d5400e2be3b985512c3fdbbc67e1
python3 -m venv .venv
source .venv/bin/activate
pip install -r pip-requirements.txt
export CLANGPDB_AARCH64_PREFIX=aarch64-linux-gnu-
python Platforms/Meizu/m2381Pkg/DeviceBuild.py --update -t RELEASE
python build_uefi.py -d m2381 -r RELEASE
find . -maxdepth 1 -name 'Mu-m2381*.img' -print
