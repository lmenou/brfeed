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

let copts_t =
  let docs = Manpage.s_common_options in
  let force =
    let doc = "Force the command, use this with cautions." in
    Arg.(value & flag & info [ "force" ] ~docs ~doc)
  in
  let verb =
    let doc = "Suppress informational output." in
    let quiet = (Brfeed.Cmds.Quiet, Arg.info [ "q"; "quiet" ] ~docs ~doc) in
    let doc = "Give verbose output." in
    let verbose =
      (Brfeed.Cmds.Verbose, Arg.info [ "v"; "verbose" ] ~docs ~doc)
    in
    Arg.(last & vflag_all [ Brfeed.Cmds.Quiet ] [ quiet; verbose ])
  in
  Term.(const Brfeed.Cmds.copts $ verb $ force)

let help_secs =
  [
    `S Manpage.s_common_options;
    `P "These options are common to all commands.";
    `S "MORE HELP";
    `P "Use $(mname) $(i,COMMAND) --help for help on a single command.";
  ]

let sdocs = Manpage.s_common_options

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
      `Blocks help_secs;
    ]
  in
  let info = Cmd.info "add" ~doc ~sdocs ~man in
  Cmd.v info Term.(const Brfeed.Cmds.add $ copts_t $ author $ feed)

let check =
  let doc = "Check the connection to a live brainfeed service." in
  let man =
    [
      `S Manpage.s_description;
      `P
        "Check if you could connect to the remote brainfeed service. \
         Effectively perform a request to the remote server. You need an \
         internet for this to function.";
      `Blocks help_secs;
    ]
  in
  let info = Cmd.info "check" ~doc ~sdocs ~man in
  Cmd.v info Term.(const Brfeed.Cmds.check $ copts_t)

let main =
  let doc = "Brainfeed's companion to manage your RSS feed database." in
  let man =
    [
      `S Manpage.s_description;
      `P "$(tname) help in managing your remote RSS brainfeed database.";
      `Blocks help_secs;
    ]
  in
  let info = Cmd.info "brfeed" ~version:"%%VERSION%%" ~doc ~sdocs ~man in
  Cmd.group info [ add; check ]

let () = exit (Cmd.eval main)
