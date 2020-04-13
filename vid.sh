#!/bin/bash

#ls -1 ./aligned/* > filtered.txt
#for i in $(ls *.jpg); do exiv2 -r '%Y-%m-%d_%H-%M-%S.:basename:' rename $i; done

OUT_FOLDER=/mnt/dulap/timelapse/face_lapse
MUZICA_GEN=../proiecte/python/timelapse/linux/muzica_random.py
MUZICA_FILE=/mnt/dulap/timelapse/concat/muzica_random.txt

rsync -av --ignore-existing /mnt/nfs/diverse/camera/mihai/ $OUT_FOLDER/input_large
for file in $OUT_FOLDER/input_large/*.jpg; do
    filename=$(basename $file)
    if [ ! -f $OUT_FOLDER/input/$filename ]; then
        echo 'resize '$filename
    	convert $OUT_FOLDER/input_large/$filename -resize 1600x1200 -gravity center -background black -extent 1600x1200 $OUT_FOLDER/input/$filename
    fi
done
# source ./.venv/bin/activate
./pada.py align
# deactivate
python $MUZICA_GEN
ffmpeg -y -threads 6 -loglevel error -framerate 15/1 -i $OUT_FOLDER/aligned/%08d.jpg -f concat -safe 0 -i $MUZICA_FILE -shortest -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart -r 30 $OUT_FOLDER/out/face_lapse_15.mp4
python $MUZICA_GEN
ffmpeg -y -threads 6 -loglevel error -framerate 10/1 -i $OUT_FOLDER/aligned/%08d.jpg -f concat -safe 0 -i $MUZICA_FILE -shortest -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart -r 30 $OUT_FOLDER/out/face_lapse_10.mp4
python $MUZICA_GEN
ffmpeg -y -threads 6 -loglevel error -framerate 5/1 -i $OUT_FOLDER/aligned/%08d.jpg -f concat -safe 0 -i $MUZICA_FILE -shortest -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart -r 30 $OUT_FOLDER/out/face_lapse_5.mp4
python $MUZICA_GEN
printf "file '%s'\n" $OUT_FOLDER/input/*.jpg > $OUT_FOLDER/input.txt
ffmpeg -y -threads 6 -loglevel error -f concat -safe 0 -i $OUT_FOLDER/input.txt -f concat -safe 0 -i $MUZICA_FILE -shortest -r 15/1 -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart -r 30 $OUT_FOLDER/out/face_lapse_input.mp4

# 60 fps muzica rapida
# ffmpeg -y -threads 6 -loglevel error -framerate 60/1 -i "/mnt/dulap/timelapse/face_lapse/aligned/%08d.jpg" -i '/mnt/dulap/timelapse/muzica/Volcano_Trap.mp3' -filter:a "atempo=2.0,atempo=2.0" -shortest -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart -r 60 "/mnt/dulap/timelapse/face_lapse/out/face_lapse_60.mp4"