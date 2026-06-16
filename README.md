# Papers Template

A small, reproducible template for writing academic papers in LaTeX and preparing
submissions for arXiv. It includes a Docker-based LaTeX build, optional DOCX
conversion through Pandoc, linting hooks, and a predictable paper directory
layout.

<div align="center">

<img
  src="assets/papers-template.png"
  alt="Papers Template"
  align="center"
  width="720px"
/>

</div>

<!-- BEGIN_AUTO_BADGES -->
<div align="center">

[![Pre-Commit](https://github.com/GangGreenTemperTatum/papers-template/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/GangGreenTemperTatum/papers-template/actions/workflows/pre-commit.yaml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

</div>
<!-- END_AUTO_BADGES -->

## What is included

- `paper/main.tex`: the root LaTeX document.
- `paper/section/*.tex`: section files included by `main.tex`.
- `paper/bibliography.bib`: bibliography entries.
- `scripts/compile.sh`: local PDF and DOCX build script.
- `scripts/prepare_for_arxiv.sh`: arXiv submission package builder.
- `justfile`: common setup, linting, and build commands.
- `.github/`: issue templates, PR template, and CI workflows.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [just](https://github.com/casey/just)
- [uv](https://github.com/astral-sh/uv)
- [pre-commit](https://pre-commit.com/)

The build commands run TeX Live and Pandoc in Docker containers, so no local
LaTeX installation is required.

## Setup

```bash
just init
source .venv/bin/activate
```

Manual setup:

```bash
uv sync
pre-commit install
```

## Writing a paper

1. Replace the title, author block, and document details in `paper/main.tex`.
2. Add paper content under `paper/section/`.
3. Add bibliography entries to `paper/bibliography.bib`.
4. Add figures under `paper/figures/` if needed.
5. Update this README with your paper title, links, citation, and release notes.

## Building

```bash
# Build paper/main.pdf
just build-paper

# Build paper/paper.docx
just build-docx

# Build both formats
just build-all-paper-formats
```

The final PDF is written to `paper/main.pdf`.

## arXiv submission

```bash
./scripts/prepare_for_arxiv.sh
```

The script builds the paper, copies only submission files into a temporary
directory, and writes `arxiv_submission.tar.gz` at the repository root.

## Overleaf

Overleaf is optional. If you want to sync this repository with Overleaf, use
Overleaf's Git integration:

https://www.overleaf.com/learn/how-to/Git_Integration_and_GitHub_Synchronization

## Linting

```bash
# Install pre-commit hooks
pre-commit install

# Run hooks against all files
just lint
```

## Citation

After publishing the paper, replace this placeholder with the preferred
citation.

```bibtex
@misc{your-paper-key,
  title        = {Your Paper Title},
  author       = {Your Name},
  year         = {2026},
  url          = {https://github.com/GangGreenTemperTatum/papers-template}
}
```

## Contributing

Forks and contributions are welcome. See the
[contributing guide](.github/CONTRIBUTING.md) for pull request guidelines.

## Security

See the [security policy](SECURITY.md) for vulnerability reporting guidance.
