let cut_at c s =
  match String.index_opt s c with Some i -> String.sub s 0 i | None -> s

let path url = url |> cut_at '?' |> cut_at '#' |> String.lowercase_ascii
let has_suffix url suffix = Filename.check_suffix (path url) suffix
let looks_like_audio url = has_suffix url ".mp3" || has_suffix url ".m4a"
let extension url = if has_suffix url ".m4a" then ".m4a" else ".mp3"
