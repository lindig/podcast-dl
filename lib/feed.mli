(** Minimal RSS/Atom podcast feed reader. *)

type episode = { title : string option; audio_url : string option }
(** Feed order is preserved (newest first in a typical podcast feed). *)

val parse : string -> (episode list, string) result
(** [parse xml] extracts every [<item>] / [<entry>]. The audio URL is the first
    enclosure whose MIME type mentions "audio" or whose URL ends in [.mp3] /
    [.m4a]. *)
