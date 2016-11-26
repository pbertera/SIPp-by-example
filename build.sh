#!/bin/bash


pandoc README.md -o index.html -f markdown --template template/standalone.html --css template/template.css --toc --toc-depth=2
