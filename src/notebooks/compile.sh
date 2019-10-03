#!/usr/bin/env bash

Rscript -e "rmarkdown::render('data-creation.Rmd')"
Rscript -e "rmarkdown::render('fpse-bot-cwe-mc-presentation.Rmd')"
Rscript -e "rmarkdown::render('sdb-dbp-we-vp-presentation.Rmd')"
Rscript -e "rmarkdown::render('ac-fp-lp-vd-presentation.Rmd')"

# copy pptx files to directory
if not exists 'G:\Projects\Safety-Security\Monthly Crime Mapping\2019\August' mkdir 'G:\Projects\Safety-Security\Monthly Crime Mapping\2019\August'

move 'fpse-bot-cwe-mc-presentation.pptx' 'G:\Projects\Safety-Security\Monthly Crime Mapping\2019\August'
move 'sdb-dbp-we-vp-presentation.pptx' 'G:\Projects\Safety-Security\Monthly Crime Mapping\2019\August'
move 'ac-fp-lp-vd-presentation.pptx' 'G:\Projects\Safety-Security\Monthly Crime Mapping\2019\August'
