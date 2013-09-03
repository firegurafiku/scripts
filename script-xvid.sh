#!/bin/sh

SOURCEFILE="$1" &&
TARGETFILE="$2" &&
RAWFILE="$SOURCEFILE.raw" &&
transcode -x mplayer -i "$SOURCEFILE" -J stabilize &&
transcode -x mplayer -i "$SOURCEFILE" -J transform -y raw -o "$RAWFILE" &&
mencoder "$RAWFILE" -vf denoise3d,scale=1024:576 \
    -ovc xvid -xvidencopts trellis:hq_ac:bitrate=2500:pass=1 \
    -oac copy -o /dev/null &&
mencoder "$RAWFILE" -vf denoise3d,scale=1024:576 \
    -ovc xvid -xvidencopts trellis:hq_ac:bitrate=2500:pass=2 \
    -oac mp3lame -lameopts vbr=3 -o "$TARGETFILE"

[ -f "$RAWFILE" ] && rm "$RAWFILE"
