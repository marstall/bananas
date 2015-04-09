#!/usr/bin/env bash
# This script assumes that ImageMagick is installed and the convert command is accessible via the $PATH variable

# Ensure that one argument has been passed in.
if [ ! "$#" -eq 1 ]
then
	echo -e "This script requires one argument.\\ne.g. iOS_icon_maker.sh app_icon.png"
	exit 1
fi

# Assign the argument to the path variable so it is easier to follow throughout the script.
path=$1

# Ensure that the path points to a valid file.
if [ ! -f "$path" ]
then
	echo "Path must point to a valid file."
	exit 1
fi

# This function takes in the dimension of the icon (it assumes the icon is a square) and the name of the file to save the icon to.
function createIconImage()
{
	iconDimension=$1
	iconName=$2

	convert "$path" -resize ${iconDimension}x${iconDimension}^ -gravity center -extent ${iconDimension}x${iconDimension} $iconName
}

# Create all the suggested icons for both the iPhone and iPad platforms to ensure the best appearance.
createIconImage 29 29_icon_settings.png
createIconImage 57 57_icon_settings@2x.png
createIconImage 114 114_icon_settings@2x.png
createIconImage 58 58_icon_settings@2x.png
createIconImage 87 87_icon_settings@3x.png
createIconImage 40 40_icon_spotlight.png
createIconImage 80 80_icon_spotlight@2x.png
createIconImage 120 120_icon_spotlight@3x.png
createIconImage 120 120_icon_iphone@2x.png
createIconImage 180 180_icon_iphone@3x.png
createIconImage 1024 1024_iTunesArtwork@2x

