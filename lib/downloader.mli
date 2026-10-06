(** Drives the whole job: fetch feeds, pick the latest episodes, download. *)

val run : base_dir:string -> max_episodes:int -> Podcast.t list -> int
(** Processes each podcast in order, printing progress to stdout. Existing files
    are skipped. Returns the number of failures (feeds that could not be
    fetched/parsed plus episodes that failed to download). *)
