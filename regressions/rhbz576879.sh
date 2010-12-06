#!/bin/bash -
# libguestfs
# Copyright (C) 2010 Red Hat Inc.
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
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Regression test for:
# https://bugzilla.redhat.com/show_bug.cgi?id=576879
# upload loses synchronization if the disk is not mounted

set -e

rm -f test1.img

# Somewhere after 1.7, the first test started to hang.
#
# Somewhere between ~ 1.5.23 and ~ 1.5.24 the second test started
# to hang.
#
# We don't understand why.  I have disabled this test and reopened
# the upstream bug.
# -- RWMJ 2010-12-06

../fish/guestfish -N disk <<EOF
-upload $srcdir/rhbz576879.sh /test.sh
# Shouldn't lose synchronization, so next command should work:
ping-daemon
EOF

# Second patch tests the problem found in comment 5 where both ends
# send cancel messages simultaneously.

../fish/guestfish -N disk <<EOF
-tar-in /tmp/nosuchfile /blah
ping-daemon
EOF

rm -f test1.img