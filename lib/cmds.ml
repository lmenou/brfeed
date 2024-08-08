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
      let answer = Request.send uri `GET in
      show answer verb

let connect verb =
  let uri = Uri.make ~scheme:"http" ~host:"localhost" ~port:4040 ~path:"/" () in
  let answer = Request.send uri `GET in
  show answer verb

type v = ValidUri of Uri.t | InvalidUri

let delete verb author feed =
  let uri =
    Uri.make ~scheme:"http" ~host:"localhost" ~port:4040 ~path:"/delete" ()
  in
  let nuri =
    match (author, feed) with
    | Some auth, Some fe ->
        ValidUri (Uri.with_query uri [ ("author", [ auth ]); ("feed", [ fe ]) ])
    | Some auth, None -> ValidUri (Uri.with_query uri [ ("author", [ auth ]) ])
    | None, Some fe -> ValidUri (Uri.with_query uri [ ("feed", [ fe ]) ])
    | None, None ->
        Stdio.eprintf "%s\n%s\n%s\n" "Warning: Author is empty"
          "Request ill-constructed" "Don't send";
        InvalidUri
  in
  match nuri with
  | InvalidUri ->
      Stdio.eprintf "%s\n%s\n%s\n" "Warning: Author is empty"
        "Request ill-constructed" "Don't send";
      ()
  | ValidUri uri ->
      let answer = Request.send uri `POST in
      show answer verb

let update verb author feed nauthor nfeed =
  let _ = verb in
  let _ = author in
  let _ = feed in
  let _ = nauthor in
  let _ = nfeed in
  Stdio.print_endline "coucou"
