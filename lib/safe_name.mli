(** Making strings safe to use as file or directory names. *)

val sanitize : string -> string
(** Removes characters that are problematic on macOS/Windows
    (angle brackets, colon, double quote, slashes, pipe, question mark,
    asterisk), collapses runs of whitespace, trims, and limits the
    result to 180 bytes without cutting a UTF-8 character in half.
    May return the empty string. *)
