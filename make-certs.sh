#!/bin/sh
# Copyright 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PASSWDS="$USER,hello"

help() {
    cat <<EOF
       usage: make-certs.sh [-h] [-a] -p user1,pass1,user2,pass2,...

       optional arguments:
       -h        show this help message and exit.
       -p        list of username password pairs.  Defaults to: [${PASSWDS}]
EOF
    exit 1
}

panic() {
    echo $1
    exit 1
}

generate_keys() {
    # Generate the adb public key, if it does not exist
    if [ ! -f ~/.android/adbkey ]; then
        local ADB=adb
        if [ ! command -v $ADB ] >/dev/null 2>&1; then
            ADB=$ANDROID_SDK_ROOT/platform-tools/adb
            command -v $ADB >/dev/null 2>&1 || panic "No adb key, and adb not found in $ADB, make sure ANDROID_SDK_ROOT is set!"
        fi
        echo "Creating public key from private key with $ADB"
        $ADB keygen ~/.android/adbkey
    fi
}

while getopts 'hasip:' flag; do
    case "${flag}" in
    p) PASSWDS="${OPTARG}" ;;
    h) help ;;
    *) help ;;
    esac
done

# Make sure we have all we need for adb to succeed.
generate_keys
# Copy the private adbkey over
cp ~/.android/adbkey env/certs/

# Now generate the public/private keys and salt the password
pip install -r ./android-emulator-container-scripts/js/jwt-provider/requirements.txt
cd env/certs
python ../../android-emulator-container-scripts/js/jwt-provider/gen-passwords.py --pairs "${PASSWDS}" || exit 1
