# l5vel.com

Static marketing site for L5VEL's S-bots, served by GitHub Pages from `main`
at the apex domain in [`CNAME`](CNAME). No build step, no dependencies — what
is in the repo is what ships.

## Layout

```
index.html              home page (company overview + product cards)
sbot/index.html         S-bot product page   -> l5vel.com/sbot/
mpep/index.html         A-MPEP product page  -> l5vel.com/mpep/
blog/index.html         Blogs listing        -> l5vel.com/blog/
blog/<slug>/index.html  one post per folder  -> l5vel.com/blog/<slug>/
blog/<slug>/reference/  optional detail page -> l5vel.com/blog/<slug>/reference/
404.html                not-found page
assets/
  css/site.css          all styles, for every page
  js/site.js            nav scroll state, video coordination (progressive enhancement)
  video/hero.mp4        hero background loop (silent)
  video/vision/         Unreal Engine concept renders, 16:9, silent
  video/progress/       real S-bot development footage, 9:16, with audio
  video/mpep/           A-MPEP test footage, 16:9, silent
  video/blog/           clips used in posts, 4:3, silent, each with a .vtt track
  posters/              poster frame per clip, mirroring the video folders
  img/                  still photography
  img/blog/<slug>/      figure images for one post
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

## The blog

`blog/index.html` lists posts; each post is its own folder with an `index.html`,
so the URL is `l5vel.com/blog/<slug>/`. There is no feed and no post index file —
adding a post means writing the page and adding one `<li class="post-card">` to
the listing.

Posts reuse the shared `.article` styles in `site.css`. Charts are either inline
SVG or generated SVG assets; neither needs client-side JavaScript. Video clips
go through the same `tools/encode-media.sh` as the rest of the site, with `blog`
as the section.

### sBot-Datasets

Two pages, deliberately split:

- `blog/sbot-datasets/index.html` — the post. Start with the table-cleaning
  episode, explain what readers can do with the data, show the generation,
  alignment and import workflows, summarize the evidence, and help readers try
  one episode. Keep provenance and the limits of the evaluation visible.
- `blog/sbot-datasets/reference/index.html` — the detail. Per-dataset table,
  format specification, camera layout, annotation variation, access recipes,
  full evaluation results and charts, metric definitions and reproduction.

Lead with a concrete use before explaining a feature or implementation detail.
The visualizer is not part of this release. Detailed methods belong in the
reference so the main post stays focused on using the data and annotation tool.
Keep the token comparison plot beside its takeaway in the post (Figure 2);
the reference repeats it as Figure R7 with the full methodology and source data.

New datasets should change the reference page and, at most, one summary
sentence in the post. If the post starts listing datasets again, it has drifted.

**Annotation provenance — get this right.** The 6,882 published subtask spans
have mixed provenance. Publication-run receipts mark 5,201 spans in 895 episodes
as imported reference annotations and 1,681 spans in 602 episodes as generated;
two imported episodes have empty tracks. Four repositories are entirely
imported-reference, five are generated, and `base4-mobile-door` mixes 150
imported-reference with 50 generated episodes. The receipts do not prove who
authored the imported files and do not identify the generation model or revision.
The pipeline targeted ten task paraphrases; 1,482 episodes retain ten alternatives
and 17 retain nine, plus the canonical task. `plan` rows are deterministically
derived from the published subtask sequence. Do not call the collection
"human-annotated" or attribute generation to a specific model without a durable
run record. Corpus A's evaluation uses imported source references only and
excludes the generated collection components. Check figure captions, table
captions, SVG `<desc>` and `<meta>` tags when updating this claim.

**Credit upstream.** `lerobot-align` is a modified and extended version of
LeRobot's steerable annotation pipeline (`lerobot-annotate`,
<https://huggingface.co/docs/lerobot/en/annotation_pipeline>), not a new system —
its own NOTICE says "extracted from LeRobot's steerable annotation pipeline and
then extended", and the ten inherited prompt templates are byte-identical. Ours
are: native video, boundary calibration, and the fixed-label alignment mode. The
evaluation baseline is real upstream code, `lerobot` 0.6.1 invoked as
`lerobot.scripts.lerobot_annotate`.

**Evaluation scope.** Subtask annotation only. Interjections and VQA were off on
every arm; task descriptions, paraphrases and memory were never scored against
reference annotations. Do not generalise any result to them or to "dataset quality".
The headline run is fixed-label alignment (labels given, timing predicted,
within-tool). Figure R7 compares contact-sheet and native-video visual tokens on
the same held-out fixed-label population. It is not a comparison with upstream.

The runtime table reports a separate run of the tool over the same source
recordings, published to a scratch namespace, purely to measure throughput.

**Every number is traceable, and most were computed rather than quoted.**
Dataset statistics come from each repository's `meta/info.json`,
`meta/tasks.parquet` and `meta/episodes/*.parquet`; the annotation statistics
come from parsing the `language_persistent` column of every data shard.
Accuracy figures come from L5VEL's internal alignment study; the page says so
where it uses them. Figure R7's processor-token rows, summary, validation and plot
are under `evaluation/public_artifacts/frame_format_tokens/` in the public
`lerobot-align` repository. The pages distinguish measured from derived figures
with `.tag--measured` / `.tag--derived` / `.tag--absent`.

Figures are numbered `1..n` in the post and `R1..Rn` in the reference, so a
cross-page mention is never ambiguous.

**Claims on these pages are deliberately hedged**, and the hedging is load
bearing: "a *declared* 50 Hz", "subtasks in 1,497 of 1,499 episodes", "not
established" rather than "no effect", results tied to the corpus and denominator
they came from. Do not tighten this prose into stronger claims. In particular,
**do not revive the old cross-format percentage**. Its arithmetic used total
vLLM server tokens despite being labelled prompt tokens, and that server counter counted the modalities inconsistently. Figure R7 now
uses a separate matched-frame census of processor-expanded visual tokens from
`image_grid_thw` and `video_grid_thw`: 55.60% fewer on 757 L5VEL trajectories
and 54.21% fewer on 1,305 RH20T trajectories. Keep the claim limited to visual
tokens under the stated 2 fps, 300-frame, 224-pixel protocol. It does not
establish billing, generated-token, latency or accuracy savings; the wall-clock
result also remains confounded by prefix-cache reuse.

If a dataset is re-uploaded, the figures go stale. Recompute them rather than
editing by hand.

## Notes

- Posters must match their video's aspect ratio. Progress clips are vertical
  (9:16) and are letterboxed rather than cropped, so the subject stays in frame.
- Media lives in git, so the repo is large. Re-encode before committing rather
  than committing a file twice.
