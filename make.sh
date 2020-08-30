#!/bin/bash

if [[ $OSTYPE == "darwin"* ]]; then
  export INKSCAPE=/Applications/Inkscape.app/Contents/MacOS/inkscape
else
  export INKSCAPE=/usr/bin/inkscape
fi

if [ ! -f $INKSCAKE ]; then
  echo "Inkscape executable is invalid"
  echo "Was expected at $INKSCAPE"
  exit 1
fi

if [ ! -x "$(command -v epstopdf)" ]; then
  echo "epstopdf is not installed"
  exit 1
fi

epsToPDF () {	
    # Build path without extension.
	filename=$(basename "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"
	dir=$(dirname $1)

	extensionless=$dir/$filename

  # -nt = newer than. -ot = older than.
	if [ "$extensionless".eps -nt "$extensionless".pdf ]; then
		echo "Convert $extensionless.eps to PDF."
    epstopdf "$extensionless".eps
  fi
  # epstopdf $filename
}

svgToPNG() {
    # Build path without extension.
  filename=$(basename "$1")
    extension="${filename##*.}"
    filename="${filename%.*}"
  dir=$(dirname $1)

  extensionless=$dir/$filename

  src="`pwd`/screenshots_svg/$filename".svg
  dst="`pwd`/screenshots/$filename".png
  # Low RES assets
  # -nt = newer than. -ot = older than.
  if [ ${src} -nt ${dst} ]; then
    echo "Convert $extensionless.svg to PNG (100dpi)."
    ${INKSCAPE} --export-png=${dst} --without-gui --export-dpi=100 ${src} > /dev/null 2>&1
  fi

  dst="`pwd`/screenshots_300dpi/$filename".png
  # High RES assets
  # -nt = newer than. -ot = older than.
  if [ ${src} -nt ${dst} ]; then
    echo "Convert $extensionless.svg to PNG (300dpi)."
    ${INKSCAPE} --export-png=${dst} --without-gui --export-dpi=300 ${src} > /dev/null 2>&1
  fi

}

# Convert eps to pdf if necessary
find . -name "*.eps" | while read file; do epsToPDF "$file"; done

#Convert complex svg drawings to PNG.
find screenshots_svg -name "*.svg" | while read file; do svgToPNG "$file"; done


# Compile
[ ! -d output ] && mkdir output
[ ! -d build ] && mkdir build

cd src
pdflatex -output-directory ../output book.tex
cd ..

cp output/book.pdf build/book.pdf
