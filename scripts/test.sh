#!/bin/sh
# for each directory in the current directory look for a file called main.tex and run pdflatex on it

for d in */ ; do
  cd $d
  if [ -f "main.tex" ]; then
    echo "compile: $d" 
    pdflatex -interaction=batchmode -recorder -file-line-error main.tex > /dev/null
    zathura main.pdf > /dev/null &
  fi
  cd ..
done
