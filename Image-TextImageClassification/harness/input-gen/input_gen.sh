# -*-Mode: sh;-*-

#*BeginCopyright*************************************************************
#
# $HeadURL$
# $Id$
#
#----------------------------------------------------------------------------
# SEAK: Suite for Embedded Applications and Kernels (hpc.pnnl.gov/SEAK/)
#----------------------------------------------------------------------------
#
# Copyright ((c)) 2016, Battelle Memorial Institute
#
# 1. Battelle Memorial Institute (hereinafter Battelle) hereby grants
#    permission to any person or entity lawfully obtaining a copy of
#    this software and associated documentation files (hereinafter "the
#    Software") to redistribute and use the Software in source and
#    binary forms, with or without modification.  Such person or entity
#    may use, copy, modify, merge, publish, distribute, sublicense,
#    and/or sell copies of the Software, and may permit others to do so,
#    subject to the following conditions:
#    
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimers.
#
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in
#      the documentation and/or other materials provided with the
#      distribution.
#
#    * Other than as used herein, neither the name Battelle Memorial
#      Institute or Battelle may be used in any form whatsoever without
#      the express written consent of Battelle.
#
#    * Redistributions of the software in any form, and publications
#      based on work performed using the software should include the
#      following citation as a reference:
#            
#        Nitin A. Gawande, Seunghwa Kang, Joseph B. Manzano, Nathan
#        R. Tallent, Darren J. Kerbyson, Adolfy Hoisie.  "SEAK
#        Specification." Pacific Northwest National Laboratory. May,
#        2016, http://hpc.pnnl.gov/SEAK/
#
# 2. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BATTELLE
#    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#    SUCH DAMAGE.
#
#*EndCopyright***************************************************************

#!/bin/bash

# INSTRUCTIONS
# 1. install ImageMagick (http://www.imagemagick.org/script/index.php)
# 2. set IMAGEMAGICK_PATH to point the directory ImageMagick is installed.
# 3. set IMAGE_DATA_PATH to point the directory containing input files (undistorted images).
#    folder extract folder images from file harness/data/images.tgz
# 4. set SEAK_INPUT_DATA_PATH to point the direcotry to store output files (distorted images).
# 5. set DISTORTION to apply desired distortions.
# 6. run this script. 

# ImageMagick convert options (see http://www.imagemagick.org/script/convert.php for full details)
# -auto-gamma: automagically adjust gamma level of image
# -auto-level: automagically adjust color levels of image
# -background color: set background color, e.g. -background black
# -brightness-contrast bxc: improve brightness/contrast of the image, b=brightness (from -100 to 100, 0 for no change), c=contrast (from -100 to 100, 0 for no change), e.g. -brightness-contrast 5x5
# -blur radius: reduce image noise and reduce detail levels, e.g. -blur 3
# -crop wxh+x+y: crop the image, w=width, h=height, x=x offset, y=y offset, e.g. -crop 28x28+0+0
# -rotate degrees: apply Paeth rotation to the image, e.g. -rotate 5
# -sharpen radius: sharpen the image, e.g. -sharpen 3
# -resize wxh: resize the image, w=width, h=height, e.g. -resize 28x28

# We make use three cases to generate input dataset for easy, medium, and hard case.
# Please select appropriate case
#input_gen_mode="easy"
input_gen_mode="medium"
#input_gen_mode="hard"

# Set path 
IMAGEMAGICK_PATH=/usr/bin
echo "ImageMagic Path = $IMAGEMAGICK_PATH"
IMAGE_DATA_PATH="$(cd ../data/images; pwd)"
echo "Image Data folder Path = $IMAGE_DATA_PATH"
SEAK_INPUT_DATA_PATH="$(cd ../inout; pwd)"
echo "SEAK Input Data Images Path = $SEAK_INPUT_DATA_PATH"

if [ "$input_gen_mode" = "easy" ]
then 
DISTORTION='-auto-gamma -auto-level -background black -brightness-contrast 5x5 -blur 3 -rotate 5 -crop 28x28+0+0 -sharpen 1 -resize 28x28'
echo "USING $input_gen_mode MODE"
elif [ "$input_gen_mode" = "medium" ]
then

DISTORTION='-auto-gamma -auto-level -background black -brightness-contrast 10x10 -blur 3 -rotate 10 -crop 28x28+0+0 -sharpen 2 -resize 28x28'

echo "USING $input_gen_mode MODE"
elif [ "$input_gen_mode" = "hard" ]
then

DISTORTION='-auto-gamma -auto-level -background black -brightness-contrast 15x15 -blur 3 -rotate 20 -crop 28x28+0+0 -sharpen 3 -resize 28x28'

echo "USING $input_gen_mode MODE"
fi

for file in ${IMAGE_DATA_PATH}/*.bmp
do
	file_nopath=$(basename $file)
	echo ${IMAGEMAGICK_PATH}/convert ${DISTORTION} $file ${SEAK_INPUT_DATA_PATH}/${file_nopath}
	${IMAGEMAGICK_PATH}/convert ${DISTORTION} $file ${SEAK_INPUT_DATA_PATH}/${file_nopath}
done

