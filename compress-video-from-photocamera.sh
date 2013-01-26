#! /bin/sh
HELP='''
Helper script for encoding video from my photocamera (Fujifilm T-300).
It is here only to reduce typing and not to memorize the entire command line.
Usage: compress-video-from-photocamera.sh INPUT_AVI OUTPUT_AVI
--
Written by Firegurafiku, Aug 2012.
Licensed under the terms of WTFPL of any version.
'''

if [ $# -lt 2 ]; then
    echo "$HELP"
    exit
fi

INPUTFILE="$1"
OUTFILE="$2"
WAVFILE=`mktemp --suffix .wav`
MP3FILE=`mktemp --suffix .mp3`

lav2wav -I "$INPUTFILE" | sox -t .wav - -r 44100 -s -c 1 "$WAVFILE" || exit 1
twolame "$WAVFILE" "$MP3FILE" || exit 2

mencoder \
    -oac mp3lame \
    -audiofile "$MP3FILE" \
    -audio-demuxer 17 \
    -ovc lavc \
    -lavcopts vcodec=msmpeg4:mbd=2:vbitrate=2500 \
    -o "$OUTFILE" "$INPUTFILE" || exit 3

rm "$WAVFILE" "$MP3FILE"

