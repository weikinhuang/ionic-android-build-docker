FROM fedora:latest

# install dependencies
RUN dnf install -y \
        curl \
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

# setup android env variables
ENV ANDROID_HOME           /opt/android-sdk-linux
ENV PATH                   ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
ENV JAVA_HOME              /usr/lib/jvm/java-1.8.0-openjdk

# android sdk version
ENV ANDROID_SDK_VERSION    24.4.1

# a csv of android api levels
ENV ANDROID_API_LEVELS     android-22
ENV ANDROID_BUILD_TOOLS    23.0.1

# download the android sdk
RUN curl -sSL http://dl.google.com/android/android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz \
        | tar -C /opt -xz

# install android sdk tools
RUN echo -e y \
    | android update sdk --no-ui --all --force --filter platform-tools,build-tools-${ANDROID_BUILD_TOOLS},extra-android-support,${ANDROID_API_LEVELS}

# install spoon for google console deploys
ENV SUPPLY_VERSION         0.6.2
RUN gem install --no-ri --no-rdoc supply -v ${SUPPLY_VERSION}

# install node
ENV NODE_VERSION           5.10.1
RUN curl -sSLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
    && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
    && rm "node-v$NODE_VERSION-linux-x64.tar.gz"

# install ionic dependencies
ENV CORDOVA_VERSION        6.1.1
ENV IONIC_VERSION          1.7.14
ENV GULP_VERSION           3.9.1
RUN npm install --global --quiet --production \
        cordova@${CORDOVA_VERSION} \
        ionic@${IONIC_VERSION} \
        gulp-cli@${GULP_VERSION} \
    && npm cache clear
