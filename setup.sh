#!/bin/sh

git clone https://github.com/tiberiuichim/fullstack-skeleton .skel

if [ -d frontend ]; then
  mv .skel/_frontend/* ./frontend/
  rm -rf .skel/_frontend
fi;

cp -r .skel/* .
mv env.example .env
mv README.md.new README.md
rm -rf .skel
