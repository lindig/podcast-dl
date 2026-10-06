(** Helpers for URLs that point at audio files. *)

val extension : string -> string
(** [".m4a"] or [".mp3"], guessed from the URL path (default [".mp3"]). *)

val looks_like_audio : string -> bool
(** The URL path ends in [.mp3] or [.m4a]. *)
