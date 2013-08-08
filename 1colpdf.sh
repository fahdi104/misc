#!/bin/bash
# Usage: 1colpdf *.pdf,  where the pdf files are proceeding files in 2 columns
# Creates 1col-*.pdf file, 1-column files for ebook readers
# Author: Hector Levesque
# Website: http://www.cs.toronto.edu/~hector/freestuff.html
# Needs: pdftex pdfinfo

for SOURCE in $@
do

SIZE=`pdfinfo $SOURCE | grep "Page size:" | grep letter`
if [ "foo$SIZE" = "foo" ]
  then echo 'Not letter size PDF'
       exit
fi

PAGES=`pdfinfo $SOURCE | grep Pages: | sed -e 's/.*: *\([0-9]*\)/\1/'`

pdftex -interaction batchmode \
"\\def\\pdffile{$SOURCE}" \
"\\def\\pageCount{$PAGES}" \
'\csname pdfmapfile\endcsname{}' \
'\pdfpagewidth=300bp\relax' \
'\def\title{\pdfvorigin=375bp\relax\pdfpageheight=100bp\relax' \
'  \setbox0=\hbox{\pdfximage width 400bp page 1{\pdffile}' \
'    \pdfrefximage\pdflastximage}' \
'  \pdfhorigin=-53bp\relax\ht0=\pdfpageheight' \
'  \shipout\box0\relax}' \
'\def\page#1{' \
'  \setbox0=\hbox{\pdfximage width 745bp page #1{\pdffile}' \
'    \pdfrefximage\pdflastximage}' \
'  \pdfhorigin=-64bp\relax\ht0=\pdfpageheight' \
'  \shipout\box0\relax' \
'  \setbox0=\hbox{\pdfximage width 745bp page #1{\pdffile}' \
'    \pdfrefximage\pdflastximage}' \
'  \pdfhorigin=-387bp\relax\ht0=\pdfpageheight' \
'  \shipout\box0\relax}' \
'\def\allpages#1{\pdfvorigin=105bp\relax\pdfpageheight=795bp\relax' \
'  \count0=1\relax ' \
'  \loop\page{\the\count0}\ifnum\count0<#1\advance\count0by1\repeat}' \
'\title\allpages{\pageCount}' \
'\csname @@end\endcsname' \
'\end'

echo "Creating 1col-$SOURCE"
mv texput.pdf 1col-$SOURCE
rm texput.*

done




