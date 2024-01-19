#!/bin/bash
#run pdflatex on main.tex in batch mode
#wait 250 ms
#run biber on main.bcf
#wait 250 ms
#run pdflatex again on main.tex in batch mode

pdflatex -interaction=batchmode main.tex && sleep 0.25 && biber main.bcf && sleep 0.25 && pdflatex -interaction=batchmode main.tex
