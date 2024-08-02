(lang dune 3.16)

(name brfeed)

(generate_opam_files true)

(source
 (github lmenou/brfeed))

(authors "lmenou")

(maintainers "lmenou")

(license GPL-3.0-or-later)

(package
 (name brfeed)
 (synopsis "Interact with brainfeed server via the terminal.")
 (description "A command line interface tool to interact with brainfeed, an RSS feed server.")
 (depends
   ocaml
   dune
   cmdliner
   curses
   base
   stdio
   (ocaml-lsp-server :build)
   (ocamlformat :build)
   (utop :build)
   (alcotest :with-test)
   (odoc :with-doc)
   (odig :with-doc))
 (tags (cli rss)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
