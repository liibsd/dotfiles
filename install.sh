#!/usr/bin/env sh
which doas >/dev/null 2>&1 && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | doas tee /etc/doas.conf }
