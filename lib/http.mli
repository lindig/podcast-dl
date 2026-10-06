(** Blocking HTTP via libcurl. Errors are human-readable strings. *)

val get_string : string -> (string, string) result
(** Fetches a URL into memory (follows redirects, accepts gzip). *)

val download :
  url:string ->
  dest:string ->
  on_progress:(downloaded:int -> total:int -> unit) ->
  (int, string) result
(** Streams [url] to [dest] and returns the number of bytes written.
    Data goes to [dest ^ ".part"] first and is renamed on success, so an
    interrupted download never leaves a truncated [dest]. [total] is [0]
    when the server sends no length. *)
