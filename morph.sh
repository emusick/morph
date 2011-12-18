#!/bin/bash
#
# Converts flac to sequential wav files for mastering
# Transcodes flac to wav, ogg, and aac formats
# Generates playlists from flac and ogg
# Batch converts ipod_list.txt from flac to ogg for Rockbox use
#
# Usage: morph.sh <option>

function flac_wav {
    echo "Convert flac to wav"
    echo -ne "Enter directory: "
    read tdir

    echo ""
    
    cdir="$(pwd)"
    cd "${tdir}"
    
    for i in *.flac; do
        echo "Converting: $i"
        track=$(metaflac --show-tag=TRACKNUMBER "${i}" | sed 's/TRACKNUMBER=//')
        flac -d "${i}" -o "${cdir}/track_${track}.wav"
    done
}

function flac_ogg {
    echo "Convert flac to ogg"
    echo -ne "Enter directory: "
    read tdir

    echo ""

    find "${tdir}" -iname "*.flac" | while read i; do
        echo "Converting: $i"
        filename=$(basename "${i}" .flac)
        oggenc -q 6 "${i}" -o "${filename}.ogg"
    done
}

function flac_aac {
    echo "This is a stub function"
}

function ipod {
    cat ipod_list.lst | while read i; do
    echo "Converting: $i"

    filename=$(basename "${i}" .flac)
    album=$(metaflac --show-tag=ALBUM "${i}" | sed 's/ALBUM=//')
    artist=$(metaflac --show-tag=ARTIST "${i}" | sed 's/ARTIST=//')

    if [ ! -e "${artist}/${album}" ]; then mkdir -p "${artist}/${album}"; fi
                                                                                    oggenc -q 6 "${i}" -o "${artist}/${album}/${filename}.ogg"
                                                                                    done
}


function morph_playlist {
    echo "Playlist generator"
    echo -ne "Enter directory: "
    read tdir

    echo ""

    cdir="$(pwd)"
    cd "${tdir}"

    for i in *.flac; do
        track=$(metaflac --show-tag=TRACKNUMBER "${i}" | sed 's/TRACKNUMBER=//')
        track=$(echo $track | sed 's/^0//')
        zplay[${track}]="${tdir}/${i}"
    done
    
    echo "#EXTM3U" > "${cdir}/playlist.m3u"
    
    for j in "${zplay[@]}"; do
        echo "${j}" >> "${cdir}/playlist.m3u"
    done
}

function morph_ogg_playlist {
    echo "Playlist generator"
    echo -ne "Enter directory: "
    read tdir
    
    echo ""

    pls="$(pwd)/playlist$$.m3u"

#BEGIN
cdir="$(pwd)"
cd "${tdir}"

for i in *.ogg; do
#if [ $(ogginfo "${i}" | grep Domination) ]; then
track=$(ogginfo "${i}" | grep TRACKNUMBER | sed 's/TRACKNUMBER=//')
track=$(echo $track | sed 's/^0//')
zplay[${track}]="${tdir}/${i}"
#fi
done
#END

#    find "${tdir}" -iname "*.ogg" | while read i; do
#        track=$(ogginfo "${i}" | grep TRACKNUMBER | sed 's/TRACKNUMBER=//')
#        track=$(echo $track | sed 's/^0//')
#        zplay[${track}]="${i}"
#    done
   
    echo "#EXTM3U" > "${pls}"
    
    for j in "${zplay[@]}"; do
        echo "${j}" >> "${pls}"
    done

    echo "Playlist ${pls} created!"
}

function morph_help {
    echo "Usage: morph.sh <option>"
    echo "Options:"
    echo "  w   -- decode flac to wav"
    echo "  o   -- decode flac to ogg"
    echo "  a   -- decode flac to aac"
    echo "  p   -- generate playlists"
    echo "  g   -- generate ogg lists"
    echo "  i   -- recover ipod songs"
    exit 0 
}

if [ $# -ne 1 ]; then
    morph_help
    exit 1
fi

if   [ "$1" == "w" ]; then
    flac_wav
elif [ "$1" == "o" ]; then
    flac_ogg
elif [ "$1" == "a" ]; then
    flac_aac
elif [ "$1" == "p" ]; then
    morph_playlist
elif [ "$1" == "g" ]; then
    morph_ogg_playlist
elif [ "$1" == "i" ]; then
    ipod
elif [ "$1" == "h" ]; then
    morph_help
else
    morph_help
fi

exit 0
