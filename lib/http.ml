let () =
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  at_exit Curl.global_cleanup

let ( let* ) = Result.bind

let with_handle f =
  let h = Curl.init () in
  Curl.set_useragent h "podcast-dl-ocaml/0.1";
  Curl.set_followlocation h true;
  Curl.set_maxredirs h 10;
  Curl.set_failonerror h true;
  Curl.set_connecttimeout h 60;
  (* Like a read timeout: abort if under 1 byte/s for 60 s. *)
  Curl.set_lowspeedlimit h 1;
  Curl.set_lowspeedtime h 60;
  Fun.protect ~finally:(fun () -> Curl.cleanup h) (fun () -> f h)

let perform h url =
  Curl.set_url h url;
  match Curl.perform h with
  | () -> Ok ()
  | exception Curl.CurlException (code, _, _) -> Error (Curl.strerror code)

let get_string url =
  let buf = Buffer.create 65536 in
  let* () =
    with_handle (fun h ->
        Curl.set_encoding h Curl.CURL_ENCODING_ANY;
        Curl.set_writefunction h (fun s ->
            Buffer.add_string buf s;
            String.length s);
        perform h url)
  in
  Ok (Buffer.contents buf)

let remove_quietly path = try Sys.remove path with Sys_error _ -> ()

let transfer oc ~url ~on_progress =
  let written = ref 0 in
  let write_error = ref None in
  let write s =
    match output_string oc s with
    | () ->
        written := !written + String.length s;
        String.length s
    | exception Sys_error msg ->
        write_error := Some msg;
        0
  in
  let result =
    with_handle (fun h ->
        Curl.set_writefunction h write;
        Curl.set_noprogress h false;
        Curl.set_progressfunction h (fun total now _ _ ->
            on_progress ~downloaded:(int_of_float now)
              ~total:(int_of_float total);
            false);
        perform h url)
  in
  match (!write_error, result) with
  | Some msg, _ -> Error msg
  | None, (Error _ as e) -> e
  | None, Ok () -> (
      match close_out oc with
      | () -> Ok !written
      | exception Sys_error msg -> Error msg)

let download ~url ~dest ~on_progress =
  let part = dest ^ ".part" in
  match open_out_bin part with
  | exception Sys_error msg -> Error msg
  | oc -> (
      let result =
        Fun.protect
          ~finally:(fun () -> close_out_noerr oc)
          (fun () -> transfer oc ~url ~on_progress)
      in
      match result with
      | Error _ as e ->
          remove_quietly part;
          e
      | Ok n -> (
          match Sys.rename part dest with
          | () -> Ok n
          | exception Sys_error msg ->
              remove_quietly part;
              Error msg))
