#
# Variables / Defaults
#

_default:
	@just --list --unsorted

#
# Setup / Init
#

[private]
@check-command command:
    command -v {{command}} >/dev/null 2>&1 || (echo "\nCommand '{{command}}' not found. Please install it.\n" && exit 1)

[private]
@deactivate:
    if [ -n "${VIRTUAL_ENV:-}" ]; then echo "Deactivated venv - try again."; deactivate; fi

[private]
@check-dependencies:
    just check-command docker
    just check-command python3
    just check-command just
    just check-command pre-commit

[group('setup')]
[doc('Initialize the project')]
@init: deactivate check-dependencies setup-hooks
    @echo "Initializing the project with uv and python 3.11..."
    @uv venv --python 3.11
    @uv sync
    @echo "papers-template project initialized successfully."
    @echo "To activate the virtual environment, run: source .venv/bin/activate"

[private]
@setup-hooks:
    pre-commit install

#
# Workspace Management
#

[group('lint')]
[doc('Update pre-commit hooks to latest versions')]
@update-hooks:
    pre-commit autoupdate
    @echo "Pre-commit hooks updated successfully"

[group('lint')]
[doc('Run pre-commit hooks on all files')]
@lint:
    pre-commit run --all-files

[group('lint')]
[doc('Run pre-commit hooks on staged files')]
@lint-staged:
    pre-commit run

#
# Documentation
#

[group('docs')]
[doc('Build the paper as PDF')]
@build-paper:
    mkdir -p build
    docker pull registry.gitlab.com/islandoftex/images/texlive:latest
    docker run --rm -v {{justfile_directory()}}/paper:/workdir registry.gitlab.com/islandoftex/images/texlive:latest /bin/sh -c "pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex"
    mv paper/paper.aux paper/paper.log paper/paper.out paper/paper.bbl paper/paper.blg build/ 2>/dev/null || true
    @echo "PDF generated at paper/main.pdf"

[group('docs')]
[doc('Convert paper to DOCX format')]
@build-docx: build-paper
    docker pull pandoc/core:latest
    docker run --rm -v {{justfile_directory()}}/paper:/data pandoc/core:latest --from latex --to docx /data/main.tex -o /data/paper.docx
    @echo "DOCX generated at paper/paper.docx"

[group('docs')]
[doc('Build all paper formats')]
@build-all-paper-formats: build-paper build-docx
    @echo "All paper formats built successfully"

#
# Troubleshooting
#
