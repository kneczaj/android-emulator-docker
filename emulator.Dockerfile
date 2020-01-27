FROM python:3.5-alpine AS build

WORKDIR /usr/src/app

RUN apk add --no-cache build-base

COPY ./android-emulator-container-scripts/emu ./emu
COPY ./emu_tools ./emu_tools
COPY ./android-emulator-container-scripts/js ./js
COPY ./android-emulator-container-scripts/setup.py \
    ./android-emulator-container-scripts/versioneer.py \
    ./android-emulator-container-scripts/README.md \
    ./android-emulator-container-scripts/setup.cfg \
    ./android-emulator-container-scripts/LICENSE \
    ./

RUN pip3 install --upgrade pip setuptools
RUN python3 ./setup.py build
RUN python3 ./setup.py install

# first acceptance does not work, a bug probably
RUN emu-docker licenses --accept
RUN emu-docker licenses --accept
RUN emu-docker licenses --accept

ARG TAG="google_apis"
ARG API="29"
ARG ABI="x86_64"

RUN export API_LETTER=`python3 ./emu_tools/api_number_to_letter.py $API` && emu-docker create --no-metrics "stable" "$API_LETTER $TAG $ABI"

FROM debian:stretch-slim AS emulator

# Install all the required emulator dependencies.
# You can get these by running ./android/scripts/unix/run_tests.sh --verbose --verbose --debs | grep apt | sort -u
# pulse audio is needed due to some webrtc dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
# Emulator & video bridge dependencies
    libc6 libdbus-1-3 libfontconfig1 libgcc1 \
    libpulse0 libtinfo5 libx11-6 libxcb1 libxdamage1 \
    libnss3 libxcomposite1 libxcursor1 libxi6 \
    libxext6 libxfixes3 zlib1g libgl1 pulseaudio socat \
# Enable turncfg through usage of curl
    curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Now we configure the user account under which we will be running the emulator
RUN mkdir -p /android/sdk/platforms && \
    mkdir -p /android/sdk/platform-tools && \
    mkdir -p /android/sdk/system-images/android && \
    mkdir -p /android-home

# Make sure to place files that do not change often in the higher layers
# as this will improve caching.
COPY --from=build /usr/src/app/src/launch-emulator.sh /android/sdk/
COPY --from=build /usr/src/app/src/platform-tools/adb /android/sdk/platform-tools/adb
COPY --from=build /usr/src/app/src/default.pa /etc/pulse/default.pa

RUN gpasswd -a root audio && \
    chmod +x /android/sdk/launch-emulator.sh /android/sdk/platform-tools/adb

COPY --from=build /usr/src/app/src/avd/ /android-home
COPY --from=build /usr/src/app/src/emu/ /android/sdk/
COPY --from=build /usr/src/app/src/sys/ /android/sdk/system-images/android/
# Create an initial snapshot so we will boot fast next time around,
# This is currently an experimental feature, and is not easily configurable//
# RUN --security=insecure cd /android/sdk && ./launch-emulator.sh -quit-after-boot 120

# This is the console port, you usually want to keep this closed.
EXPOSE 5554

# This is the ADB port, useful.
EXPOSE 5555

# This is the gRPC port, also useful, we don't want ADB to incorrectly identify this.
EXPOSE 8556

ENV ANDROID_SDK_ROOT /android/sdk
ENV ANDROID_AVD_HOME /android-home
WORKDIR /android/sdk

# You will need to make use of the grpc snapshot/webrtc functionality to actually interact with
# the emulator.
CMD ["/android/sdk/launch-emulator.sh"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
CMD /android/sdk/platform-tools/adb shell getprop dev.bootcomplete | grep "1"
