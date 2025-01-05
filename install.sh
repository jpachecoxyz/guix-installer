#!/bin/sh
set -e
set -o pipefail

log_error() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $1" >&2
	exit 1
}

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting cow-store service..." && herd start cow-store /mnt || log_error "Failed to start cow-store."
log "Copying channels.scm..." && cp /etc/channels.scm /mnt/etc && chmod +w /mnt/etc/channels.scm || log_error "Failed to copy or modify channels.scm."
log "Copying config.scm..." && cp /mnt/etc/config.scm ./config.scm || log_error "Failed to copy config.scm."
log "Adding nongnu modules and linux kernel to config.scm ..."
if ! grep -q '(use-modules (gnu) (nongnu packages linux))' ./config.scm; then
	sed -i 's/(use-modules (gnu))/(use-modules (gnu) (nongnu packages linux))/' ./config.scm || log_error "Failed to add (nongnu packages linux) to use-modules."
else
	log "Line '(use-modules (gnu) (nongnu packages linux))' already exists. Skipping."
fi

if ! grep -q '(kernel linux)' ./config.scm; then
	sed -i '/(operating-system/a\
  (kernel linux)\
  (firmware (list linux-firmware))' ./config.scm || log_error "Failed to add kernel and firmware configurations."
else
	log "Kernel and firmware configurations already exist. Skipping."
fi
log "Copying updated config.scm back to /mnt/etc..." && cp ./config.scm /mnt/etc/config.scm || log_error "Failed to copy updated config.scm back to /mnt/etc."
log "Initializing system with guix time-machine..." && guix time-machine -C /mnt/etc/channels.scm -- system init /mnt/etc/config.scm /mnt || log_error "System initialization failed."
log "Clean this folder..." && rm ./config.scm 

log "Script completed successfully."
