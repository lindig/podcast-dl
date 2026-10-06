let ( let* ) = Result.bind

let rec mkdir_p path =
  if Sys.file_exists path then
    if Sys.is_directory path then Ok ()
    else Error (path ^ " exists and is not a directory")
  else
    let* () = mkdir_p (Filename.dirname path) in
    try Ok (Sys.mkdir path 0o755) with Sys_error msg -> Error msg
