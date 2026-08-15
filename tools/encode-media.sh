#!/bin/bash
# Encode a source clip for the web and extract a matching poster frame.
#
#   tools/encode-media.sh raw/clip.mov vision   pouring-tea
#   tools/encode-media.sh raw/clip.mp4 progress opening-doors
#   tools/encode-media.sh raw/clip.mp4 hero
#
# Produces H.264 with +faststart (so playback starts before the file finishes
# downloading) and drops audio tracks that are digitally silent.
set -euo pipefail

if [ "$#" -lt 2 ]; then
    sed -n '2,9p' "$0"
    exit 1
fi

src=$1
section=$2
slug=${3:-}

repo=$(cd "$(dirname "$0")/.." && pwd)
[ -f "$src" ] || { echo "no such file: $src" >&2; exit 1; }

case "$section" in
    hero)
        out="$repo/assets/video/hero.mp4"
        poster="$repo/assets/posters/hero.jpg"
        crf=26
        ;;
    vision|progress)
        [ -n "$slug" ] || { echo "a slug is required for $section" >&2; exit 1; }
        out="$repo/assets/video/$section/$slug.mp4"
        poster="$repo/assets/posters/$section/$slug.jpg"
        [ "$section" = vision ] && crf=26 || crf=27
        ;;
    *)
        echo "section must be one of: hero, vision, progress" >&2
        exit 1
        ;;
esac

mkdir -p "$(dirname "$out")" "$(dirname "$poster")"

# Drop the audio track if there is none, or if it is effectively silent.
aopt="-c:a aac -b:a 96k -ac 2"
if ! ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "$src" | grep -q .; then
    aopt="-an"
else
    peak=$(ffmpeg -hide_banner -nostats -i "$src" -af volumedetect -f null - 2>&1 |
           sed -n 's/.*max_volume: \(-\{0,1\}[0-9.]*\) dB.*/\1/p')
    if [ -n "$peak" ] && awk -v p="$peak" 'BEGIN{exit !(p < -60)}'; then
        echo "audio is silent (${peak} dB peak) — dropping the track"
        aopt="-an"
    fi
fi

echo "encoding $src -> ${out#"$repo"/}"
ffmpeg -y -hide_banner -loglevel error -i "$src" \
    -c:v libx264 -profile:v high -level 4.0 -preset slow -crf "$crf" \
    -pix_fmt yuv420p -movflags +faststart $aopt "$out"

# Poster: a representative frame ~12% in, at the video's own aspect ratio.
dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$out")
start=$(awk -v d="$dur" 'BEGIN{printf "%.2f", d*0.12}')
ffmpeg -y -hide_banner -loglevel error -ss "$start" -i "$out" \
    -vf "thumbnail=200,scale='if(gt(iw,ih),min(1280,iw),-2)':'if(gt(iw,ih),-2,min(1280,ih))'" \
    -frames:v 1 -q:v 4 "$poster"

read -r w h <<< "$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height \
                   -of csv=p=0:nk=1 "$out" | tr ',' ' ')"

echo
echo "  video  ${out#"$repo"/}   ${w}x${h}  $(du -h "$out" | cut -f1)"
echo "  poster ${poster#"$repo"/}  $(du -h "$poster" | cut -f1)"

if [ "$section" != hero ]; then
    echo
    echo "markup:"
    echo "    <video controls preload=\"none\" playsinline"
    echo "           poster=\"assets/posters/$section/$slug.jpg\""
    echo "           aria-label=\"DESCRIBE THE CLIP\">"
    echo "        <source src=\"assets/video/$section/$slug.mp4\" type=\"video/mp4\">"
    echo "        Your browser does not support the video tag."
    echo "    </video>"
fi
