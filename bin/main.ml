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

open Cmdliner

let add =
  let author =
    let doc = "The author's name of the RSS blog." in
    Arg.(
      value
      & opt (some string) None
      & info [ "a"; "author" ] ~docv:"AUTHOR" ~doc)
  in
  let feed =
    let doc = "The RSS feed address." in
    Arg.(
      value & opt (some string) None & info [ "f"; "feed" ] ~docv:"FEED" ~doc)
  in
  let doc = "Add an RSS feed to the remote database." in
  let man =
    [
      `S Manpage.s_description;
      `P
        "Add an RSS feed to the remote brainfeed database. Effectively perform \
         a request to the remote server. You need an internet for this to \
         function.";
    ]
  in
  let info = Cmd.info "add" ~doc ~man in
  Cmd.v info Term.(const Brfeed.Cmds.adder $ author $ feed)

let main =
  let doc = "Brainfeed's companion to manage your RSS feed database." in
  let man =
    [
      `S Manpage.s_description;
      `P "$(tname) help in managing your remote RSS brainfeed database.";
    ]
  in
  let info = Cmd.info "brfeed" ~version:"%%VERSION%%" ~doc ~man in
  Cmd.group info [ add ]

let () = exit (Cmd.eval main)
