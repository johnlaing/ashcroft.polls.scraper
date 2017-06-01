#!/bin/bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <DL dir>"
  exit 1
fi
DL_DIR=$1

UNZIP_DIR=$(echo $DL_DIR | sed 's/^downloads/unzipped/')
mkdir -p $UNZIP_DIR

for f in $DL_DIR/Welcome*.zip; do
  echo $f
  unzip $f Welcome.xlsx -d $UNZIP_DIR
  new_f=$(basename $f | sed 's/zip$/xlsx/')
  mv $UNZIP_DIR/Welcome.xlsx $UNZIP_DIR/$new_f
done
