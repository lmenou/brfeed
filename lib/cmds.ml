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

let copts verb = verb

type check = Not | Yes of string * string

let check author feed =
  match (author, feed) with
  | None, Some _ ->
      Stdio.eprintf "%s\n%s\n%s\n" "Warning: Author is empty"
        "Request ill-constructed" "Don't send";
      Not
  | Some _, None ->
      Stdio.eprintf "%s\n%s\n%s\n" "Warning: Feed is empty"
        "Request ill-constructed" "Don't send";
      Not
  | None, None ->
      Stdio.eprintf "%s\n%s\n%s\n" "Warning: Feed AND Author are empty!"
        "Request ill-constructed" "Do not send unless --force is used";
      Not
  | Some author, Some feed -> Yes (author, feed)

let show response verbose =
  match response with
  | Request.Ok (resp, body) -> (
      match verbose with
      | Verbose ->
          Stdio.printf "%s %d %s\n" "OK:"
            (Http.Status.to_int resp.status)
            (Request.Body.to_string body)
      | Quiet -> Stdio.printf "%s %d\n" "OK" (Http.Status.to_int resp.status))
  | Request.Bad (resp, body) -> (
      match verbose with
      | Verbose ->
          Stdio.printf "%s %d %s\n" "Error:"
            (Http.Status.to_int resp.status)
            (Request.Body.to_string body)
      | Quiet -> Stdio.printf "%s %d" "Error" (Http.Status.to_int resp.status))
  | Request.Error -> (
      match verbose with
      | Verbose -> Stdio.printf "%s %s\n" "Internal Error:" "Report the bug."
      | Quiet -> Stdio.printf "%s\n" "Error")

let add verb author feed =
  let ok = check author feed in
  match ok with
  | Not -> ()
  | Yes (au, fe) ->
      let uri =
        Uri.make ~scheme:"http" ~host:"localhost" ~port:4040 ~path:"/add"
          ~query:[ ("author", [ au ]); ("feed", [ fe ]) ]
          ()
      in
      let _ = print_endline (Uri.to_string uri) in
      let answer = Request.send uri `GET in
      show answer verb

let check verb =
  let uri = Uri.make ~scheme:"http" ~host:"localhost" ~port:4040 ~path:"/" () in
  let answer = Request.send uri `GET in
  show answer verb
