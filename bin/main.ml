open Cmdliner
open Podcast_dl

let dir =
  let doc = "Base directory; one sub-directory is created per podcast." in
  Arg.(value & opt string "./podcasts" & info [ "d"; "dir" ] ~docv:"DIR" ~doc)

let episodes =
  let doc = "Number of latest episodes to download per podcast." in
  Arg.(value & opt int 5 & info [ "n"; "episodes" ] ~docv:"N" ~doc)

let feeds =
  let doc =
    "Podcast to download, as NAME=RSS_URL. Repeatable. When given, replaces \
     the built-in list (The Talk Show, Accidental Tech Podcast)."
  in
  Arg.(
    value
    & opt_all (pair ~sep:'=' string string) []
    & info [ "f"; "feed" ] ~docv:"NAME=URL" ~doc)

let run base_dir max_episodes feeds =
  let podcasts =
    match feeds with
    | [] -> Podcast.defaults
    | fs -> List.map (fun (name, feed_url) -> { Podcast.name; feed_url }) fs
  in
  if Downloader.run ~base_dir ~max_episodes podcasts = 0 then 0 else 1

let cmd =
  let doc = "download the latest episodes of selected podcasts" in
  let info = Cmd.info "podcast-dl" ~version:"0.1.0" ~doc in
  Cmd.v info Term.(const run $ dir $ episodes $ feeds)

let () = exit (Cmd.eval' cmd)
