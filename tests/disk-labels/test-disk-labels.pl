#!/usr/bin/perl
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

# Test using the 'label' option of add_drive, and the
# list_disk_labels call.

use strict;
use warnings;

use Sys::Guestfs;

my $g = Sys::Guestfs->new ();

# Add two drives.
foreach (["test1.img", "a"], ["test2.img", "b"]) {
    my ($output, $label) = @$_;
    open FILE, ">$output" or die "$output: $!";
    truncate FILE, 512 * 1024 * 1024 or die "$output: truncate: $!";
    close FILE or die "$output: $!";
    $g->add_drive ($output, readonly => 0, format => "raw", label => $label);
}

$g->launch ();

# Partition the drives.
$g->part_disk ("/dev/disk/guestfs/a", "mbr");
$g->part_init ("/dev/disk/guestfs/b", "mbr");
$g->part_add ("/dev/disk/guestfs/b", "p", 64, 100 * 1024 * 2 - 1);
$g->part_add ("/dev/disk/guestfs/b", "p", 100 * 1024 * 2, -64);

# Check the partitions exist using both the disk label and raw name.
die unless
    $g->blockdev_getsize64 ("/dev/disk/guestfs/a1") ==
    $g->blockdev_getsize64 ("/dev/sda1");
die unless
    $g->blockdev_getsize64 ("/dev/disk/guestfs/b1") ==
    $g->blockdev_getsize64 ("/dev/sdb1");
die unless
    $g->blockdev_getsize64 ("/dev/disk/guestfs/b2") ==
    $g->blockdev_getsize64 ("/dev/sdb2");

# Check list_disk_labels
my %labels = $g->list_disk_labels ();
die unless exists $labels{"a"};
die unless $labels{"a"} eq "/dev/sda";
die unless exists $labels{"b"};
die unless $labels{"b"} eq "/dev/sdb";
die unless exists $labels{"a1"};
die unless $labels{"a1"} eq "/dev/sda1";
die unless exists $labels{"b1"};
die unless $labels{"b1"} eq "/dev/sdb1";
die unless exists $labels{"b2"};
die unless $labels{"b2"} eq "/dev/sdb2";

unlink "test1.img";
unlink "test2.img";

exit 0