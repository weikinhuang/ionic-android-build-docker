# Ionic Android Build

![Ionic Framework](http://ionicframework.com/img/ionic-logo-blue.svg)
[Ionic Framework](http://ionicframework.com/) is an open source front-end SDK for developing hybrid mobile apps with web technologies.

## Docker Build Base Image

This image provides a base image for which Ionic based android apps can be built upon or extended from to create an development environment.

## How to use this image

### Use this image to build an ionic app

```bash
$ docker run -it --rm --name ionic-app -v "$PWD":/usr/src/app -w /usr/src/app weikinhuang/ionic-android-build create-release-apk
```

### Create a Dockerfile in your Ionic app project
```dockerfile
FROM weikinhuang/ionic-android-build

# expose the ionic development ports
EXPOSE 8100 35729

# copy project
COPY . /data

# set up ionic requirements
WORKDIR /data

# restore ionic state
RUN npm install --quiet
RUN bower install --quiet --allow-root
RUN ionic state reset
```

``` bash
$ docker run -it --rm --name ionic-app -v "$PWD"/www:/data/www -w /data -p 8100:8100 -p 35729:35729 your-ionic-app create-release-apk
```

## Tools included

### `android-sdk-install`

Use this command to install additional android sdk components without user interaction. Useful for docker build instructions.

```dockerfile
RUN android-sdk-install android-17
```

### `android-wait-for-emulator`

Use this command to wait for an headless android emulator.

See [Paul Estrada blog](http://paulemtz.blogspot.com/2013/05/android-testing-in-headless-emulator.html) on how to create a headless android image.

```bash
# start emulator
$ android -avd ...
$ android-wait-for-emulator
# run tests
```

### `create-release-apk`

Use this command to generate a release android apk file to `platforms/android/build/outputs/apk/*-release.apk`.

Automatically removes the console plugin per the [Ionic publishing docs](http://ionicframework.com/docs/guide/publishing.html).

```bash
$ create-release-apk
```

### fastlane's `supply`

Use this command to automatically publish an apk to the [Google Play Developer Console](https://play.google.com/apps/publish/)

See [supply docs](https://github.com/fastlane/fastlane/tree/master/supply) for usage.

## Enabling USB in the container

```bash
sudo docker run -it --rm --privileged -v /dev/bus/usb:/dev/bus/usb weikinhuang/ionic-android-build adb list
```

## License

[License information](https://github.com/weikinhuang/ionic-android-build-docker/LICENSE) for the software contained in this image.

## Supported Docker versions

This image is tested on Docker version 1.10.3.
