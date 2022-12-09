PYTHON=python
VENV_NAME=.venv
PYLINT=pylint
PIPY_URL=https://pypi.org/

_BLUE=\033[34m
_END=\033[0m

# canned recipe
define show =
echo -e "${_BLUE}============================================================${_END}" && \
echo -e "${_BLUE}[$@] ${1}${_END}" && \
echo -e "${_BLUE}============================================================${_END}"
endef

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${_BLUE}%-15s${_END} %s\n", $$1, $$2}'

.PHONY: lint
lint:
	-@${PYLINT} pylint_report > .pylint_report.json || exit 0
	-@pylint_report.py .pylint_report.json -o .pylint_report.html

pre-commit: ## Execute pre-commit on all files
	@pre-commit run -a

setup-venv: ## Setup empty venv
	${PYTHON} -m venv ${VENV_NAME} && \
	. ${VENV_NAME}/bin/activate && \
	pip install --upgrade pip

install-local: setup-venv ## Editable install in venv
	. ${VENV_NAME}/bin/activate && pip install -e .[dev]

dist-local: setup-venv ## Build package
	. ${VENV_NAME}/bin/activate && pip install build && ${PYTHON} -m build

publish: ## Publish to PyPi
	pip install build && ${PYTHON} -m build && pip install twine && \
	twine upload \
		--repository-url ${PIPY_URL} \
		dist/*
