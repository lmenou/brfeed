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

(** Construct a request properly and easily. *)

type r =
  | Ok of Http.Response.t * string
  | Bad of Http.Response.t * string
  | Error  (** Define the response type of a request. *)

val send : ?body:string -> Uri.t -> Http.Method.t -> r
(** [send ~body uri method] effectively send the [method] type request with the
    provided [body] (if present) to the remote [uri]. *)
