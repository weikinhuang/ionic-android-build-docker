#!/usr/bin/env bash

set -x -e

mkdir -p /data
cd /data

ionic start test-app tabs
cd test-app
ionic platform add android
ionic build android
