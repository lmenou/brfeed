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

type verb =
  | Quiet
  | Verbose  (** Define the general outputs of the command line tool *)

val copts : verb -> verb
(** Get the wished verbosity of the command *)

val add : verb -> string option -> string option -> unit
(** [adder verb author feed] add the RSS [feed] to the remote database effectively
    for the given [author], printing the response with verbosity [verb]. *)

val connect : verb -> unit
(** [check ()] attempts a connection to the remote brainfeed database. To check
    its status, printing the response with verbosity [verb]. *)

val delete : verb -> string option -> string option -> unit
(** [delete author feed] delete the RSS [feed] to the remote database
    effectively with the given [author], if [feed] is not given, then all
    entries with the given author are deleted, if [author] is not given, only
    the entry with [feed] is deleted, printing the response with verbosity [verb]. *)

val update :
  verb ->
  string option ->
  string option ->
  string option ->
  string option ->
  unit
(** [update verb author feed nauthor nfeed] update the RSS [feed] to the remote database
    effectively with the given [author], if [feed] is not given, then all
    entries with the given author are updated, if [author] is not given, only
    the entry with [feed] is updated, printing the response with verbosity [verb]. *)
