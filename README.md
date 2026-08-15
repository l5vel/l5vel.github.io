# l5vel.com

Static marketing site for L5VEL's S-bots, served by GitHub Pages from `main`
at the apex domain in [`CNAME`](CNAME). No build step, no dependencies — what
is in the repo is what ships.

## Layout

```
index.html              home page (company overview + product cards)
sbot/index.html         S-bot product page   -> l5vel.com/sbot/
mpep/index.html         A-MPEP product page  -> l5vel.com/mpep/
404.html                not-found page
assets/
  css/site.css          all styles, for every page
  js/site.js            nav scroll state, video coordination (progressive enhancement)
  video/hero.mp4        hero background loop (silent)
  video/vision/         Unreal Engine concept renders, 16:9, silent
  video/progress/       real S-bot development footage, 9:16, with audio
  video/mpep/           A-MPEP test footage, 16:9, silent
  posters/              poster frame per clip, mirroring the video folders
  img/                  still photography
tools/encode-media.sh   re-encodes source media for the web
```

The home page is a company overview: hero → products (`#products`) →
philosophy → contact (`#contact`). Each product then has its own page.

The S-bot page runs hero → where S-bots work (`#verticals`) → development
footage (`#progress`) → concept renders (`#vision`) → contact. Real footage
comes before the renders on purpose — it matches what the philosophy section
claims about showing real progress over highlight reels.

Both product pages share the `.prod-hero` / `.prod-*` styles in `site.css`,
so a third product page starts by copying either one.

## The A-MPEP page

`mpep/index.html` supports a Government proposal, so every number on it is
traceable to the independent BCDC Innovation Proving Ground *MPEP Customer
Test Report* (18 April 2023) covering the 3–10 March 2023 test, except the
host-platform specification table, which is labelled as supplier ratings.

**Do not add projected or planned capability to this page.** Work that is
proposed rather than demonstrated — GPS-denied navigation, night operation,
load ID, multi-vehicle teaming, Army logistics-system integration — is
deliberately excluded. Cite the report before adding a figure.

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
