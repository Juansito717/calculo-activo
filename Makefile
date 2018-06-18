## ********************************************************************* ##
## Copyright 2016--2017                                                  ##
## Matt Boelkins                                                         ##
##                                                                       ##
## This file is part of Active Calculus                                  ##
##                                                                       ##
## ********************************************************************* ##

#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Make a copy of Makefile.paths.original
#      as Makefile.paths, which git will ignore.
#   2) Edit Makefile.paths to provide full paths to the root folders 
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to 
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it 
# operates on very few dependencies.  It is more of a shell
# script, sharing common configurations

# Useful targets:
# make acs-extraction --- Run this any time a change is made to a WeBWorK
#                         exercise. Do not run if no such changes have been
#                         made.
# make html --- Build the HTML version. Requires that make acs-extraction have
#               been run in the past, but need not run it immediately before.
# make  pdf --- Build the PDF version. Requires that make acs-extraction have
#               been run in the past, but need not run it immediately before.
# make soln-pdf --- Make a PDF of the full solutions manual.
# make workbook-pdf --- Make a PDF of the activity workbook.
# make check --- Validate against the schema and report errors. List of errors is
#                displayed on screen and stored in output/schema_errors.txt

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Navigate to the location of this file
#	B) At command line:  make <some-target-from-the-options-below>

# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
include Makefile.paths

# These paths are subdirectories of
# the project distribution
PRJSRC    = $(PRJ)/src
OUTPUT    = $(PRJ)/output
STYLE     = $(PRJ)/style
IMAGESSRC = $(PRJSRC)/images

# The project's main hub file
MAINFILE  = $(PRJSRC)/index.xml
SOLNMAIN = $(PRJSRC)/acs-solution-manual.xml
WKBKMAIN = $(PRJSRC)/acs-activity-workbook.xml

# These paths are subdirectories of
# the Mathbook XML distribution
# MBUSR is where extension files get copied
# so relative paths work properly
MBXSL = $(MB)/xsl
MBUSR = $(MB)/user

# These paths are subdirectories of
# the scratch directory
PGOUT      = $(OUTPUT)/pg
# HTMLOUT set in Makefile.paths
# HTMLOUT    = $(OUTPUT)/html
PDFOUT     = $(OUTPUT)/pdf
WWOUT      = $(OUTPUT)/webwork-extraction
IMAGESOUT  = $(OUTPUT)/images
SOLNOUT    = $(OUTPUT)/soln-man
WKBKOUT    = $(OUTPUT)/workbook

# Some aspects of producing these examples require a WeBWorK server.
# For all but trivial testing or examples, please look into setting
# up your own WeBWorK server, or consult Alex Jordan about the use
# of PCC's server in a nontrivial capacity.    <alex.jordan@pcc.edu>
SERVER = https://webwork-ptx.aimath.org

#  Write out each WW problem as a standalone problem in PGML ready 
#  for use on a WW server.  "def" files and "header" files are 
#  produced. Directories and filenames are derived from titles of 
#  chapters, sections, etc., in addition to the titles of the 
#  problems themselves.
#
#  Results land in the subdirectory:  $(PGOUT)/local
#
pg:
	install -d $(PGOUT)
	cd $(PGOUT); \
	xsltproc -xinclude --stringparam chunk.level 2 $(MBXSL)/mathbook-webwork-archive.xsl $(MAINFILE)

#  Extract webwork problems into a single XML file called
#  webwork-extraction.xml which holds multiple versions of each problem.
#  Also locally store images from the WeBWorK server.

acs-extraction:
	install -d $(WWOUT)
	-rm $(WWOUT)/webwork-extraction.xml
	$(MB)/script/mbx -v -c webwork -d $(WWOUT) -s $(SERVER) $(MAINFILE)

#  Make a new PTX file from the source tree, with webwork elements replaced
#  by the webwork-reps from webwork-extraction.xml. (So run the above at
#  least once first.) Subsequent templates are applied to the result.

acs-merge:
	cd $(WWOUT); \
	xsltproc -xinclude  --stringparam webwork.extraction $(WWOUT)/webwork-extraction.xml $(MBXSL)/pretext-merge.xsl $(MAINFILE) > acs-merge.ptx

#  HTML output 
#  Output lands in the subdirectory:  $(HTMLOUT)
#    Remove the entire $(HTMLOUT)/knowl directory because of how PTX now
#    seems to make a knowl for everything and rm throws an error.
html: acs-merge
	install -d $(HTMLOUT)
	-rm -rf $(HTMLOUT)/knowl
	install -d $(HTMLOUT)/knowl
	install -d $(HTMLOUT)/images
	install -d $(OUTPUT)
	install -d $(OUTPUT)/images
	install -d $(MBUSR)
	install -b xsl/acs-html.xsl $(MBUSR)
	-rm $(HTMLOUT)/*.html
	cp -a $(IMAGESOUT) $(HTMLOUT)
	cp -a $(IMAGESSRC) $(HTMLOUT)
	cd $(HTMLOUT); \
	xsltproc -xinclude $(MBUSR)/acs-html.xsl $(WWOUT)/acs-merge.ptx

# make all the image files in svg format
images:
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.svg
	$(MB)/script/mbx -c latex-image -f svg -d $(IMAGESOUT) $(MAINFILE)
#	$(MB)/script/mbx -c asymptote -f svg -d $(IMAGESOUT) $(MAINFILE)

# make all the image files in pdf format
pdfimages:
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.pdf
	$(MB)/script/mbx -c latex-image -f pdf -d $(IMAGESOUT) $(MAINFILE)

# for pdf output, a one-time prerequisite for LaTeX conversion of
# problems living on a server, and image construction at server
# our "webwork-tex" is a subdirectory of where the PDF is compiled
# -s specifies an existing WW server to use (ignore security warnings)
webwork-server-tex:
	install -d $(PDFOUT)/webwork-tex
	$(MB)/script/mbx -v -c webwork-tex -s $(SERVER) -d $(PDFOUT)/webwork-tex $(MAINFILE)

# LaTeX and PDF versions,
# see prerequisite just above about merge files.
# xsltproc may be passed --stringparam latex.fillin.style box for box answer blanks
pdf: acs-merge
	install -d $(PDFOUT)
	install -d $(PDFOUT)/images
	-rm $(PDFOUT)/*.*
	-rm $(PDFOUT)/images/*
	cp -a $(WWOUT)/*.png $(PDFOUT)/images
	install -d $(MBUSR)
	install -b xsl/acs-latex.xsl $(MBUSR)
	cp -a $(IMAGESSRC) $(PDFOUT)
	cd $(PDFOUT); \
	xsltproc -xinclude $(MBUSR)/acs-latex.xsl $(WWOUT)/acs-merge.ptx; \
	sed -i ".bak" -f ../../change-documentclass.sed index.tex; \
	xelatex index; \
	xelatex index

# Solutions manual (LaTeX only for PDF)
# see prerequisite just above
# the "webwork-tex" directory must be given here
# [note trailing slash (subject to change)]
# Need this to ensure all the numbering is right.
soln-latex:
	install -d $(SOLNOUT)
	install -d $(MBUSR)
	install -b xsl/acs-solution-manual.xsl $(MBUSR)
	-rm $(SOLNOUT)/*.tex
	cp -a $(IMAGESSRC) $(SOLNOUT)
	cd $(SOLNOUT); \
	xsltproc -xinclude $(MBUSR)/acs-solution-manual.xsl $(SOLNMAIN) \

# Solutions manual for PDF
# Automatically builds LaTeX source for solutions manual
soln-pdf: soln-latex
	cd $(SOLNOUT); \
	sed -i ".bak" -f ../../change-documentclass-soln-man.sed acs-solution-manual.tex; \
	xelatex acs-solution-manual; \
	xelatex acs-solution-manual


# Activity workbook (LaTeX only for PDF)
# see prerequisite just above
# the "webwork-tex" directory must be given here
# [note trailing slash (subject to change)]
# Need this to ensure all the numbering is right.
workbook-latex:
	install -d $(WKBKOUT)
	install -d $(MBUSR)
	install -b xsl/acs-activity-workbook.xsl $(MBUSR)
	-rm $(WKBKOUT)/*.tex
	cp -a $(IMAGESSRC) $(WKBKOUT)
	cd $(WKBKOUT); \
	xsltproc -xinclude $(MBUSR)/acs-activity-workbook.xsl $(WKBKMAIN) \

# Activity workbook for PDF
# Automatically builds LaTeX source for solutions manual
workbook-pdf: workbook-latex
	cd $(WKBKOUT); \
	xelatex acs-activity-workbook; \
	xelatex acs-activity-workbook


###########
# Utilities
###########

# Verify Source integrity
#   Leaves "schema_errors.txt" in OUTPUT
#   can then grep on, e.g.
#     "element XXX:"
#     "does not follow"
#     "Element XXXX content does not follow"
#     "No declaration for"
#   Automatically invokes the "less" pager, could configure as $(PAGER)
check:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/schema_errors.*
	-java -classpath $(JING_DIR)/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration -jar $(JING_DIR)/build/jing.jar $(MB)/schema/pretext.rng $(MAINFILE) > $(OUTPUT)/schema_errors.txt
	less $(OUTPUT)/schema_errors.txt
