(* virt-sysprep
 * Copyright (C) 2012 Red Hat Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *)

open Printf

open Sysprep_operation

module G = Guestfs

let globs = List.sort compare [
  (* log files *)
  "/var/log/*.log*";
  "/var/log/audit/*";
  "/var/log/btmp*";
  "/var/log/cron*";
  "/var/log/dmesg*";
  "/var/log/lastlog*";
  "/var/log/maillog*";
  "/var/log/mail/*";
  "/var/log/messages*";
  "/var/log/secure*";
  "/var/log/spooler*";
  "/var/log/tallylog*";
  "/var/log/wtmp*";

  (* yum installation files *)
  "/root/install.log";
  "/root/install.log.syslog";
  "/root/anaconda-ks.cfg";

  (* GDM and session preferences. *)
  "/var/cache/gdm/*";
  "/var/lib/AccountService/users/*";
  "/var/lib/fprint/*";                  (* Fingerprint service files *)
]
let globs_as_pod = String.concat "\n" (List.map ((^) " ") globs)

let logfiles_perform g root =
  let typ = g#inspect_get_type root in
  if typ = "linux" then (
    List.iter (fun glob -> Array.iter g#rm_rf (g#glob_expand glob)) globs
  );
  []

let logfiles_op = {
  name = "logfiles";
  enabled_by_default = true;
  heading = "Remove many log files from the guest";
  pod_description = Some (
    sprintf "\
On Linux the following files are removed:

%s" globs_as_pod);
  extra_args = [];
  perform = logfiles_perform;
}

let () = register_operation logfiles_op