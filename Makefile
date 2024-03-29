SRCDIR=src
TMPDIR=tmp
OUTPUTDIR=out
PROJECT_FILE=gcce.sublime-project

TEXSRC=paper.tex
OUTPUTFILE=paper.pdf
BIBSRC=biblio.bib

TMP_FILES=*.aux *.gz *.log *.bbl *.blg *.snm *.nav *.toc *.out *.xdv *.toc *.lof *.loa *.lot *.idx

define whitespace
 
endef

UNAME := $(shell uname -s)

ifeq ($(UNAME), Darwin)
    XELATEX=/usr/local/texlive/2013/bin/universal-darwin/xelatex
    BIBTEX=/usr/local/texlive/2013/bin/universal-darwin/bibtex
    PDF_VIEWER=open
else
    XELATEX=xelatex
    BIBTEX=bibtex
    PDF_VIEWER=evince
endif

all: pdf view

pdf: bibtex xelatex

xelatex: mkdir-tmp mkdir-out prepare
	@${XELATEX} -synctex=1 -interaction=errorstopmode --src-specials ${TEXSRC}
	@mv -f ${subst .tex,.pdf,${TEXSRC}} ${OUTPUTDIR}/${OUTPUTFILE}
ifeq ($(UNAME), Darwin)
	@ls -1 ${TMP_FILES} 2>/dev/null | xargs -J {} mv -f {} ${TMPDIR}
else
	@ls -1 ${TMP_FILES} 2>/dev/null | xargs -i mv -f {} ${TMPDIR}
endif
	@make rm_helper

xelatex-nopdf: prepare
	@${XELATEX} -synctex=1 -interaction=errorstopmode --no-pdf --src-specials ${TEXSRC}

clean:
ifneq (${TMPDIR},.)
	@rm -fR ${TMPDIR}/*
else
	@rm ${TMP_FILES} *.pdf
endif
	@cd ${SRCDIR}; \
	rm -f ${TMP_FILES} *.pdf
	@make rm_helper


bibtex: xelatex-nopdf
	@${BIBTEX} ${subst .tex,,${TEXSRC}}
	@make xelatex-nopdf

prepare:
	@test -d ${SRCDIR} && cp -R ${SRCDIR}/* .

mkdir-src:
ifneq (${SRCDIR},.)
	@test -d ${SRCDIR} || mkdir -p ${SRCDIR}
endif

mkdir-out:
ifneq (${OUTPUTDIR},.)
	@test -d ${OUTPUTDIR} || mkdir -p ${OUTPUTDIR}
endif

mkdir-tmp:
ifneq (${TMPDIR},.)
	@test -d ${TMPDIR} || mkdir -p ${TMPDIR}
endif

mkdir: mkdir-src mkdir-tmp mkdir-out
	@touch ${SRCDIR}/${TEXSRC}
	@touch ${SRCDIR}/${BIBSRC}

init: mkdir gitignore
	@test -d .git || git init

gitignore:
	@echo "$(subst $(whitespace),\n,${TMP_FILES})" > .gitignore
	@echo ".DS_Store"		>> 	.gitignore
	@echo "${OUTPUTFILE}"	>> 	.gitignore
	@echo "${SRCDIR}/.*"	>> 	.gitignore
	@echo "${TMPDIR}/*" 	>> 	.gitignore
	@echo "${OUTPUTDIR}/*" 	>> 	.gitignore

view:
	@${PDF_VIEWER} ${OUTPUTDIR}/${OUTPUTFILE}

rm_helper:
	@./rm-helper '${SRCDIR}|${OUTPUTDIR}|${TMPDIR}|${PROJECT_FILE}|Makefile|README.md|.gitignore|.git|rm-helper'
