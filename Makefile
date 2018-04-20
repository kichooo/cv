# -----------------------------------------------------------------------------
# BUILD
# dependencies: moderncv, pdflatex, texlive-fonts-extra
# -----------------------------------------------------------------------------
.PHONY: all
all: pdf open

.PHONY: pdf
pdf:
	@pdflatex martin-cv.tex
	@echo cv was produced: open martin-cv.pdf

.PHONY: open
open:
	@xdg-open martin-cv.pdf