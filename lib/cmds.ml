(* Brainfeed server companion?
   Copyright (C) 2024 brfeed's author(s)

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see {:https://www.gnu.org/licenses/}. *)

type verb = Quiet | Verbose
type copts = { force : bool; verb : verb }

let copts verb force = { verb; force }

let add options author feed =
  let _, _ = (options.force, options.verb) in
  let auth = match author with None -> "None" | Some v -> v in
  let fe = match feed with None -> "None" | Some v -> v in
  let module S = Stdio in
  Stdio.printf "author: %s -- feed: %s" auth fe

let check () =
  let open Cohttp_eio in
  Eio_main.run @@ fun env ->
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let net = Eio.Stdenv.net env in
  let client = Client.make ~https:None net in
  try
    let resp, body =
      Client.get client (Uri.of_string "http://localhost:4040/") ~sw
    in
    if Http.Status.compare resp.status `OK != 0 then
      let _ =
        Stdio.printf "%s %d\n" "Request Error" (Http.Status.to_int resp.status)
      in
      let r = Eio.Buf_read.of_flow body ~max_size:45 in
      Stdio.print_endline (Eio.Buf_read.line r)
    else
      let r = Eio.Buf_read.of_flow body ~max_size:45 in
      Stdio.print_endline (Eio.Buf_read.line r)
    (* NOTE(lmenou): Cannot have context information ? *)
  with
  | Eio.Io (Eio.Net.E (Eio.Net.Connection_failure value), _) -> (
      match value with
      | Eio.Net.No_matching_addresses ->
          Stdio.print_endline "Could not find the address"
      | Eio.Net.Refused _ -> Stdio.print_endline "Connection denied/down"
      | Eio.Net.Timeout -> Stdio.print_endline "Timeout!")
  | Eio.Buf_read.Buffer_limit_exceeded ->
      Stdio.print_endline "Cannot handle the heavy response"
