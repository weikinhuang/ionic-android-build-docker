FROM fedora:latest
MAINTAINER Wei Kin Huang

# install dependencies
RUN dnf install -y \
        curl \
        expect \
        findutils \
        gcc \
        gcc-c++ \
        git \
        glibc \
        java-1.8.0-openjdk-devel \
        java-1.8.0-openjdk-headless \
        make \
        ruby \
        rubygems \
        tar \
        which \
        glibc.i686 \
        glibc-devel.i686 \
        libstdc++.i686 \
        ncurses-devel.i686 \
        zlib-devel.i686 \
    && dnf clean all

# script to accept android license
# https://github.com/journeyapps/android-sdk-installer
COPY utils/android-accept-licenses /usr/bin/android-accept-licenses
# script to wait for android emulator
# https://github.com/travis-ci/travis-cookbooks/blob/master/community-cookbooks/android-sdk/files/default/android-wait-for-emulator
COPY utils/android-wait-for-emulator /usr/bin/android-wait-for-emulator
COPY utils/android-sdk-install /usr/bin/android-sdk-install
COPY utils/create-release-apk /usr/bin/create-release-apk
RUN chmod +x /usr/bin/android-accept-licenses \
    && chmod +x /usr/bin/android-sdk-install \
    && chmod +x /usr/bin/android-wait-for-emulator \
    && chmod +x /usr/bin/create-release-apk

# create a development directory
RUN mkdir -p /data

# setup android env variables
ENV ANDROID_HOME            /opt/android-sdk-linux
ENV PATH                    ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV JAVA_HOME               /usr/lib/jvm/java-1.8.0-openjdk

# android sdk
ENV ANDROID_SDK_VERSION     24.4.1
RUN curl -sSL http://dl.google.com/android/android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz \
        | tar -C /opt -xz \
    && chown -R root:root ${ANDROID_HOME}
# has an error: Failed to rename directory /opt/android-sdk-linux/tools
# RUN android-sdk-install tools

# android sdk components
ENV ANDROID_CORE_LEVEL      23
ENV ANDROID_BUILD_TOOLS     23.0.3
ENV ANDROID_API_LEVELS      android-${ANDROID_CORE_LEVEL}
ENV ANDROID_GOOGLE_APIS     addon-google_apis-google-${ANDROID_CORE_LEVEL}
# http://paulemtz.blogspot.com/2013/05/android-testing-in-headless-emulator.html
# android create avd --force -n test -t android-17 --abi armeabi-v7a
# emulator -avd test -no-skin -no-audio -no-window
#ENV ANDROID_EMULATORS       sys-img-x86-android-${ANDROID_CORE_LEVEL}
ENV ANDROID_SDK_EXTRAS      extra-android-m2repository \
                            extra-android-support \
                            extra-google-admob_ads_sdk \
                            extra-google-analytics_sdk_v2 \
                            extra-google-google_play_services \
                            extra-google-gcm \
                            extra-google-m2repository \
                            extra-google-play_billing \
                            extra-google-play_licensing
ENV ANDROID_SDK_INSTALL     platform-tools \
                            build-tools-${ANDROID_BUILD_TOOLS} \
                            ${ANDROID_API_LEVELS} \
                            ${ANDROID_GOOGLE_APIS} \
                            ${ANDROID_SDK_EXTRAS} \
                            ${ANDROID_EMULATORS}

# install android sdk tools
RUN android-sdk-install "${ANDROID_SDK_INSTALL}"

# install fastlane supply for google console deploys
# https://github.com/fastlane/fastlane/tree/master/supply
ENV SUPPLY_VERSION          0.6.2
RUN gem install --no-ri --no-rdoc supply -v ${SUPPLY_VERSION}

# install node
ENV NODE_VERSION            5.10.1
RUN curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz"

# install ionic dependencies
ENV BOWER_VERSION           1.7.9
ENV CORDOVA_VERSION         6.1.1
ENV IONIC_VERSION           1.7.14
ENV GULP_VERSION            1.2.1
# install global node modules and clear cache
RUN mkdir -p \
        /tmp/.npm \
        /tmp/.npm-tmp \
    && NPM_CONFIG_CACHE=/tmp/.npm \
        NPM_CONFIG_TMP=/tmp/.npm-tmp \
        npm install --global --quiet --production \
            bower@${BOWER_VERSION} \
            cordova@${CORDOVA_VERSION} \
            ionic@${IONIC_VERSION} \
            gulp-cli@${GULP_VERSION} \
    && rm -rf \
        /tmp/.npm \
        /tmp/.npm-tmp

# pre download/install the version of gradle used for the installed version of cordova
RUN cd /tmp \
    && export NPM_CONFIG_CACHE=/tmp/.npm \
    && export NPM_CONFIG_TMP=/tmp/.npm-tmp \
    && mkdir -p \
        /tmp/.npm \
        /tmp/.npm-tmp \
    && echo n | ionic start test-app tabs \
    && cd test-app \
    && ionic platform add android \
    && ionic build android \
    && rm -rf \
        /root/.android/debug.keystore \
        /root/.config \
        /root/.cordova \
        /root/.ionic \
        /root/.v8flags.*.json \
        /tmp/.npm \
        /tmp/.npm-tmp \
        /tmp/hsperfdata_root/* \
        /tmp/ionic-starter-* \
        /tmp/native-platform*dir \
        /tmp/test-app
