#!/bin/bash -

Rscript -e "library(knitr);knit2html('./aaymca_dclean.Rmd')"
'mv' *.html ../WWW/
'rm' -Rf ../WWW/figure
'mv' ./figure ../WWW/