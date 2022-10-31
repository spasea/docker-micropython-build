#!/bin/bash

. /opt/esp/idf/export.sh && cd /micropython/ports/esp32/
make
cp -rf /micropython/ports/esp32/build-GENERIC/ /project
