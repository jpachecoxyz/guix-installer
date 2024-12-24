#!/bin/sh
herd start cow-store /mnt

cp /etc/channels.scm /mnt/etc && chmod +w /mnt/etc/channels.scm

cp /mnt/etc/config.scm .
patch config.scm < config.patch && cp config.scm /mnt/etc/config.scm
