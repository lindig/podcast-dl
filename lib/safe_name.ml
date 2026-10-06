let max_bytes = 180
let forbidden = Re.(compile (set "<>:\"/\\|?*"))
let spaces = Re.(compile (rep1 space))
let is_continuation c = Char.code c land 0xC0 = 0x80

let truncate s =
  if String.length s <= max_bytes then s
  else
    let rec cut n = if n > 0 && is_continuation s.[n] then cut (n - 1) else n in
    String.sub s 0 (cut max_bytes)

let sanitize name =
  name
  |> Re.replace_string forbidden ~by:""
  |> Re.replace_string spaces ~by:" "
  |> String.trim |> truncate |> String.trim
