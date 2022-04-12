.PHONY: clean

%.pdf: %.tex $(DEPENDS)
		@echo '.........: pdflatex running pass 1...'
		pdflatex $< -o $@ 2>&1 | tee errors.err
		@echo '.........: bibtex running...'
		bibtex $(basename $<) 2>&1 | tee errors.err
		@echo '.........: pdflatex running pass 2...'
		pdflatex $< -o $@ 2>&1 | tee errors.err
		@echo '.........: pdflatex and bibtex run finished.'

clean:
		rm -rf *.aux *.bbl *.blg *.log *.pdf *.toc *.snm *.out *.nav tags
