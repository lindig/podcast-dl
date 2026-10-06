open Podcast_dl

let sample =
  {|<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
 <channel>
  <title>Channel title</title>
  <item>
   <title>  Ep 2: A &amp; B &nbsp;  </title>
   <itunes:title>Wrong one</itunes:title>
   <enclosure url="https://x.test/e2.m4a?token=1" type="audio/x-m4a" length="1"/>
  </item>
  <item>
   <title><![CDATA[Ep 1: "Quoted"]]></title>
   <enclosure url="https://x.test/e1.mp3" length="1"/>
  </item>
  <item><title>No audio</title></item>
 </channel>
</rss>|}

let () =
  (match Feed.parse sample with
  | Error e -> failwith e
  | Ok
      [
        { title = Some t2; audio_url = Some u2 };
        { title = Some t1; audio_url = Some u1 };
        { title = Some t0; audio_url = None };
      ] ->
      assert (t2 = "Ep 2: A & B");
      assert (u2 = "https://x.test/e2.m4a?token=1");
      assert (t1 = "Ep 1: \"Quoted\"");
      assert (u1 = "https://x.test/e1.mp3");
      assert (t0 = "No audio")
  | Ok _ -> failwith "unexpected episodes");
  assert (Result.is_error (Feed.parse "<rss><item></rss>"));
  assert (Safe_name.sanitize "  a/b:c  d?  " = "abc d");
  assert (Safe_name.sanitize "///" = "");
  let long = String.concat "" (List.init 200 (fun _ -> "é")) in
  let s = Safe_name.sanitize long in
  assert (String.length s <= 180 && String.length s mod 2 = 0);
  assert (Audio_url.extension "https://x/a.M4A?x=1" = ".m4a");
  assert (Audio_url.extension "https://x/a.ogg" = ".mp3");
  print_endline "all tests passed"
