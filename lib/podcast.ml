type t = { name : string; feed_url : string }

let defaults =
  [
    {
      name = "The-Talk-Show"
    ; feed_url = "https://daringfireball.net/thetalkshow/rss"
    }
  ; { name = "ATP"; feed_url = "https://atp.fm/rss" }
  ]
