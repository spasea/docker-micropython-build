#!/bin/bash

. /opt/esp/idf/export.sh && cd /micropython/ports/esp32/
make
cp -rf /micropython/ports/esp32/build-ESP32_GENERIC/ /project
mv /project/build-ESP32_GENERIC /project/build-GENERIC
