(** Small filesystem helpers. *)

val mkdir_p : string -> (unit, string) result
(** Creates a directory and any missing parents. *)
