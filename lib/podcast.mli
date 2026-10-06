(** A podcast to download. *)

type t = { name : string; feed_url : string }

val defaults : t list
(** The built-in podcast list. *)
