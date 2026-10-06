type episode = { title : string option; audio_url : string option }

type state = {
  stack : Xmlm.name list;
  text : Buffer.t;
  current : episode option;
  finished : episode list;  (* reversed *)
}

let atom_ns = "http://www.w3.org/2005/Atom"
let attr key attrs = List.find_map (fun ((_, k), v) -> if k = key then Some v else None) attrs
let mentions_audio = Re.(execp (compile (str "audio")))

let is_audio ~mime url =
  Option.fold mime ~none:false ~some:mentions_audio || Audio_url.looks_like_audio url

let enclosure_url (_, local) attrs =
  let candidate =
    match local with
    | "enclosure" -> attr "url" attrs
    | "link" when attr "rel" attrs = Some "enclosure" -> attr "href" attrs
    | _ -> None
  in
  match candidate with
  | Some url when is_audio ~mime:(attr "type" attrs) url -> Some url
  | _ -> None

let is_item (_, local) = local = "item" || local = "entry"
let is_title (ns, local) = local = "title" && (ns = "" || ns = atom_ns)
let parent_is_item = function parent :: _ -> is_item parent | [] -> false

let add_audio ep = function
  | Some url when ep.audio_url = None -> { ep with audio_url = Some url }
  | _ -> ep

let set_title ep title =
  if ep.title = None && title <> "" then { ep with title = Some title } else ep

let start_element st name attrs =
  Buffer.clear st.text;
  let current =
    match st.current with
    | None when is_item name -> Some { title = None; audio_url = None }
    | None -> None
    | Some ep -> Some (add_audio ep (enclosure_url name attrs))
  in
  { st with stack = name :: st.stack; current }

let end_element st =
  match st.stack with
  | [] -> st
  | name :: parents -> (
      let st = { st with stack = parents } in
      match st.current with
      | None -> st
      | Some ep when is_item name ->
          { st with current = None; finished = ep :: st.finished }
      | Some ep when is_title name && parent_is_item parents ->
          let title = String.trim (Buffer.contents st.text) in
          { st with current = Some (set_title ep title) }
      | Some _ -> st)

let rec scan input st =
  if Xmlm.eoi input then List.rev st.finished
  else
    match Xmlm.input input with
    | `El_start (name, attrs) -> scan input (start_element st name attrs)
    | `El_end -> scan input (end_element st)
    | `Data d ->
        Buffer.add_string st.text d;
        scan input st
    | `Dtd _ -> scan input st

let parse xml =
  (* Feeds often contain HTML entities XML doesn't define; drop them. *)
  let input = Xmlm.make_input ~entity:(fun _ -> Some "") (`String (0, xml)) in
  let init = { stack = []; text = Buffer.create 256; current = None; finished = [] } in
  try Ok (scan input init)
  with Xmlm.Error ((line, _), err) ->
    Error (Fmt.str "XML error at line %d: %s" line (Xmlm.error_message err))
