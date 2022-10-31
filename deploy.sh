#!/bin/bash

esptool.py --port /dev/tty.usbserial-0001 -b 460800 --before default_reset \
  --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect \
  --flash_freq 40m 0x1000 build-GENERIC/bootloader/bootloader.bin \
  0x8000 build-GENERIC/partition_table/partition-table.bin \
  0x10000 build-GENERIC/micropython.bin