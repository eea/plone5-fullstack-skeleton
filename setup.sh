#!/bin/sh

git clone https://github.com/tiberiuichim/fullstack-skeleton .skel
cp -r .skel/* .
mv README.md.new README.md
rm -rf .skel
