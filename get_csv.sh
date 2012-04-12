#!/bin/sh

DATA_URL="http://oku.edu.mie-u.ac.jp/~okumura/stat/data/mhlw/"

if [ "x$1" = "x" ]; then
  DATA_DIR="/home/autch/src/foodrad/data/"
else
  DATA_DIR="$1"
fi

rm -f "$DATA_DIR/index.html"
exec wget -nv -P "$DATA_DIR" -N -p -c -r -l1 --remove-listing -np -L -nd -nH "$DATA_URL"

