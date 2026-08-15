# l5vel.com

Static marketing site for L5VEL's S-bots, served by GitHub Pages from `main`
at the apex domain in [`CNAME`](CNAME). No build step, no dependencies — what
is in the repo is what ships.

## Layout

```
index.html              the whole page
404.html                not-found page
assets/
  css/site.css          all styles
  js/site.js            nav scroll state, video coordination (progressive enhancement)
  video/hero.mp4        hero background loop (silent)
  video/vision/         Unreal Engine concept renders, 16:9, silent
  video/progress/       real development footage, 9:16, with audio
  posters/              poster frame per clip, mirroring the video folders
tools/encode-media.sh   re-encodes source media for the web
```

Page order is: hero → platform (`#verticals`) → progress (`#progress`) →
vision (`#vision`) → philosophy → contact (`#contact`). Real footage comes
before the concept renders on purpose — it matches what the philosophy
section claims about showing real progress over highlight reels.

## Working on it

Open `index.html` directly, or serve the folder so root-relative paths resolve:

```sh
python3 -m http.server 8000
```

## Adding a video

Never commit footage straight from a camera or Unreal — it is typically 5–20×
larger than it needs to be and lacks the `faststart` flag, which forces
browsers to download the entire file before playback starts.

1. Drop the source file in `raw/` (git-ignored).
2. Run `tools/encode-media.sh raw/clip.mp4 vision|progress <slug>`.

That writes `assets/video/<section>/<slug>.mp4` and a matching poster frame in
`assets/posters/<section>/<slug>.jpg`, then prints the markup to paste in.
Silent audio tracks are dropped automatically.

## Notes

- Posters must match their video's aspect ratio. Progress clips are vertical
  (9:16) and are letterboxed rather than cropped, so the subject stays in frame.
- Media lives in git, so the repo is large. Re-encode before committing rather
  than committing a file twice.
