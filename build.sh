#!/bin/bash


pandoc README.md -o index.html -f markdown --template pandoc_template/standalone.html --css pandoc_template/template.css --toc --toc-depth=2
