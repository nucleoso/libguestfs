#!/bin/bash -
# libguestfs virt-inspector test script
# Copyright (C) 2012 Red Hat Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

export LANG=C
set -e

for f in ../tests/guests/{debian,fedora,ubuntu,windows}.img; do
    ./virt-inspector -a $f
done

# We could also test this image, but mdadm is problematic for
# many users.
# ./virt-inspector \
#   -a ../tests/guests/fedora-md1.img \
#   -a ../tests/guests/fedora-md2.img