#!/usr/bin/env bash

set -xv

_deps=(debootstrap wget)
for _d in ${_deps[@]}; do command -v ${_d} || exit 127; done

_img=${1:-"kali"}

_workdir=${2:-$(mktemp -d)}
_bootstrap="${_workdir}/root"

_keyring="${_workdir}/keyring"
wget -qO- "https://archive.kali.org/archive-key.asc" | gpg --dearmor > "${_keyring}"

_conf="${_workdir}/conf"
wget -qO- "https://gitlab.com/kalilinux/packages/debootstrap/raw/kali/master/scripts/kali" | sed "s|/usr/share/keyrings/kali-archive-keyring.gpg|$_keyring|g" > "${_conf}"

debootstrap --variant=minbase --include=kali-archive-keyring kali-rolling "${_bootstrap}" "https://http.kali.org/kali" "${_conf}"
GZIP=-9 tar -C "${_bootstrap}" -c . | docker import - "${_img}"

docker build --no-cache --squash --rm -t "${_img}" -f Dockerfile .

rm -fr "${_workdir}"
