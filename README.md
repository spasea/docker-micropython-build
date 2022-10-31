### Build image

```bash
docker build -t my-esp-build .
```

### Enter container

```bash
docker run --rm -v $PWD:/project --privileged -w /project -it my-esp-build
```

### When entering container

```bash
. /opt/esp/idf/export.sh && cd /micropython/ports/esp32/
```

### Copy build

```bash
cp -rf build-GENERIC/ /build
```

### Erase board

```bash
esptool.py --port /dev/tty.usbserial-0001 erase_flash
```

### Write to board

```bash
esptool.py --port /dev/tty.usbserial-0001 -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 build-GENERIC/bootloader/bootloader.bin 0x8000 build-GENERIC/partition_table/partition-table.bin 0x10000 build-GENERIC/micropython.bin
```
