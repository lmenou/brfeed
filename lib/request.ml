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

open Base

type r =
  | Ok of Http.Response.t * string
  | Bad of Http.Response.t * string
  | Error

let send ?body uri meth =
  let module Co = Cohttp_eio in
  Eio_main.run @@ fun env ->
  Eio.Switch.run ~name:"main" @@ fun sw ->
  let net = Eio.Stdenv.net env in
  let client =
    (Co.Client.make ~https:None net
     [@ppwarning "TODO(lmenou): Deal with https at some point"])
  in
  try
    let resp, body =
      match body with
      | None -> Co.Client.call client ~sw meth uri
      | Some bod ->
          Co.Client.call client ~sw meth uri ~body:(Co.Body.of_string bod)
            ~headers:
              (Http.Header.of_list [ ("Content-Type", "application/json") ])
    in
    if not (Int.equal (Http.Status.compare resp.status `OK) 0) then
      let r = Eio.Buf_read.of_flow body ~max_size:8000 in
      Bad (resp, Eio.Buf_read.line r)
    else
      let r = Eio.Buf_read.of_flow body ~max_size:8000 in
      Ok (resp, Eio.Buf_read.line r)
    (* NOTE(lmenou): Cannot have context information ? *)
  with
  | Eio.Io (Eio.Net.E (Eio.Net.Connection_failure value), _) -> (
      match value with
      | Eio.Net.No_matching_addresses ->
          Stdio.prerr_endline "Error: Could not find the address";
          Error
      | Eio.Net.Refused _ ->
          Stdio.prerr_endline "Error: Connection denied/down";
          Error
      | Eio.Net.Timeout ->
          Stdio.prerr_endline "Error: Timeout!";
          Error)
  | Eio.Buf_read.Buffer_limit_exceeded ->
      Stdio.prerr_endline "Error: Cannot handle the heavy response";
      Error
