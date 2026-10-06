(lang dune 3.0)

(name podcast_dl)

(generate_opam_files true)

(package
 (name podcast_dl)
 (synopsis "Download the latest episodes of selected podcasts")
 (description
  "Reads podcast RSS feeds and downloads the newest N audio episodes into one directory per podcast, skipping files that already exist.")
 (depends
  (ocaml (>= 4.14))
  dune
  ocurl
  xmlm
  re
  fmt
  cmdliner))
