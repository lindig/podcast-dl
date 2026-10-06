# podcast-dl

OCaml port of `podcast.py`: downloads the latest N episodes of selected
podcasts into `<dir>/<podcast name>/`, skipping files that already exist.

## Build

    opam install . --deps-only --with-test   # ocurl xmlm re fmt cmdliner
    dune build
    dune test

(ocurl needs the libcurl development headers, e.g. `libcurl4-openssl-dev`.)

## Use

    dune exec -- podcast-dl                       # built-in list, 5 episodes each, ./podcasts
    dune exec -- podcast-dl -n 3 -d ~/Podcasts
    dune exec -- podcast-dl -f "My Show=https://example.com/feed.xml"

Exit status is 1 if any feed or download failed.

## Layout

- `lib/feed.ml`       RSS/Atom parsing (xmlm)
- `lib/http.ml`       libcurl GET and streaming download with progress
- `lib/safe_name.ml`  filename sanitising;  `lib/audio_url.ml` extension guess
- `lib/downloader.ml` orchestration;  `bin/main.ml` command line (cmdliner)
