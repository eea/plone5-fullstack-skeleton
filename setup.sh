#!/bin/sh

rm -rf .skel
git clone https://github.com/tiberiuichim/fullstack-skeleton .skel

if [ -d frontend ]; then
  mv .skel/_frontend/* ./frontend/
  rm -rf .skel/_frontend
fi;

# cp -rna .skel/* .
cp -rna .skel/backend .
cp -rna .skel/scripts .

if [ ! -f .env ]; then
  mv .skel/tpl/env .env
fi

if [ ! -f README.md ]; then
  mv .skel/tpl/README.md.tpl README.md
fi
rm -rf .skel
