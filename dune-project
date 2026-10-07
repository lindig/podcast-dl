(lang dune 3.0)

(name podcast-dl)

(generate_opam_files true)

(license Unlicense)

(source
 (github lindig/podcast-dl))

(authors "Christian Lindig <lindig@gmail.com>")

(maintainers "Christian Lindig <lindig@gmail.com>")

(package
 (name podcast-dl)
 (synopsis "Download the latest episodes of selected podcasts")
 (description
  "Reads podcast RSS feeds and downloads the newest N audio episodes into one directory per podcast, skipping files that already exist.")
 (depends
  (ocaml
   (>= 4.14))
  dune
  ocurl
  xmlm
  re
  fmt
  cmdliner))
