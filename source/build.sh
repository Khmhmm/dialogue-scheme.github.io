#!/bin/bash
SOURCE_DIR=$(pwd)
echo "Trying to build for target web..."
cd dialogue_scheme
flutter build web
echo "Move build files to base dir..."
cd build/web
for f in $(ls);
do
    rm -rf $SOURCE_DIR/../$f;
    mv $f $SOURCE_DIR/../;
    echo "-- moving " $f " to " $SOURCE_DIR/../;
done;
echo "Done. Terminating...";
