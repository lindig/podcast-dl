let ( let* ) = Result.bind
let rule = String.make 60 '='

type outcome = Downloaded | Already_there | No_audio | Failed

let take n l = List.filteri (fun i _ -> i < n) l

(* Returns a progress callback that only prints when the percentage moves. *)
let progress_printer () =
  let last = ref (-1) in
  fun ~downloaded ~total ->
    let pct = if total > 0 then downloaded * 100 / total else -1 in
    if pct >= 0 && pct <> !last then (
      last := pct;
      Fmt.pr "\r  %3d%% (%d KB)%!" pct (downloaded / 1024))

let episode_title ~index (ep : Feed.episode) =
  Option.value ep.title ~default:(Fmt.str "Episode %d" index)

let dest_path ~dir ~index ep url =
  let stem =
    match Safe_name.sanitize (episode_title ~index ep) with
    | "" -> Fmt.str "Episode %d" index
    | s -> s
  in
  Filename.concat dir (stem ^ Audio_url.extension url)

let download_episode ~dest url =
  Fmt.pr "  ↓ Downloading → %s@." (Filename.basename dest);
  match Http.download ~url ~dest ~on_progress:(progress_printer ()) with
  | Ok bytes ->
      Fmt.pr "@.  ✓ Saved (%.1f MB)@." (float_of_int bytes /. 1048576.);
      Downloaded
  | Error msg ->
      Fmt.pr "@.  ✗ Download failed: %s@." msg;
      Failed

let fetch_episode ~dir ~total ~index (ep : Feed.episode) =
  Fmt.pr "@.[%d/%d] %s@." index total (episode_title ~index ep);
  match ep.audio_url with
  | None ->
      Fmt.pr "  ⚠ No audio enclosure found – skipping@.";
      No_audio
  | Some url ->
      let dest = dest_path ~dir ~index ep url in
      if Sys.file_exists dest then (
        Fmt.pr "  ✓ Already exists → %s@." (Filename.basename dest);
        Already_there)
      else download_episode ~dest url

let load_feed url =
  let* xml = Http.get_string url in
  Feed.parse xml

let process_podcast ~base_dir ~max_episodes (p : Podcast.t) =
  Fmt.pr "@.%s@.Podcast: %s@.%s@." rule p.name rule;
  let dir = Filename.concat base_dir (Safe_name.sanitize p.name) in
  match Fs.mkdir_p dir with
  | Error msg ->
      Fmt.pr "  ✗ Cannot create %s: %s@." dir msg;
      1
  | Ok () -> (
      Fmt.pr "Fetching feed: %s@." p.feed_url;
      match load_feed p.feed_url with
      | Error msg ->
          Fmt.pr "  ✗ Failed to read feed: %s@." msg;
          1
      | Ok episodes ->
          let latest = take max_episodes episodes in
          let total = List.length latest in
          Fmt.pr "Found %d episodes in feed → processing latest %d@."
            (List.length episodes) total;
          latest
          |> List.mapi (fun i ep -> fetch_episode ~dir ~total ~index:(i + 1) ep)
          |> List.filter (fun o -> o = Failed)
          |> List.length)

let run ~base_dir ~max_episodes podcasts =
  Fmt.pr "Podcast Downloader@.Base directory: %s@.Episodes per podcast: %d@."
    base_dir max_episodes;
  let failures =
    match Fs.mkdir_p base_dir with
    | Error msg ->
        Fmt.pr "  ✗ Cannot create %s: %s@." base_dir msg;
        1
    | Ok () ->
        List.fold_left
          (fun acc p -> acc + process_podcast ~base_dir ~max_episodes p)
          0 podcasts
  in
  Fmt.pr "@.%s@.Done.@.Files are in: %s@." rule base_dir;
  failures
