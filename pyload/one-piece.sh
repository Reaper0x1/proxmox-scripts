#!/bin/sh
echo $1 $2 $3 $4 $5 

if [[ "$2" == *"OnePiece"* ]]; then

    echo "Detected One Piece episode"

    destDir="/anime/One Piece [tvdb4-81797]/Arc 33 - Egg Head Island"

    filename=$(echo "One.Piece.E$(echo "$2" | awk -F_ '{print $3}').1080p.mp4")
    echo "The new filename is $filename"
    sleep 1

    echo "Moving the episode"
    mv "$3" "$destDir/$filename"

    echo "Episode moved"

fi