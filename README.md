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
In container
```bash
cp -rf build-GENERIC/ /build
```

## Execution of esptool
In case `esptool.py` execution doesn't work for you - you can try to run it with `python -m esptool` or `python3 -m esptool`. This also is applicable to bash scripts. [Docs](https://docs.espressif.com/projects/esptool/en/latest/esp32/installation.html)

## Manual commands

### Erase board
In treminal
```bash
esptool.py --port /dev/tty.usbserial-0001 erase_flash
```

### Write to board
In treminal
```bash
esptool.py --port /dev/tty.usbserial-0001 -b 460800 --before default_reset --after hard_reset --chip esp32  write_flash --flash_mode dio --flash_size detect --flash_freq 40m 0x1000 build-GENERIC/bootloader/bootloader.bin 0x8000 build-GENERIC/partition_table/partition-table.bin 0x10000 build-GENERIC/micropython.bin
```


## Bash scripts

### Enter container
```bash
bash run.sh
```

### Build firmware
In container
```bash
bash build.sh
```

### Erase board
In treminal
```bash
bash erase.sh
```

### Write to board
In treminal
```bash
bash deploy.sh
```
