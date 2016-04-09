#!/usr/bin/env bash

set -x -e

mkdir /data
cd /data

ionic start test-app tabs
cd test-app
ionic platform add android
ionic build android
