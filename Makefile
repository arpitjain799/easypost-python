PYTHON_BINARY := python3
VIRTUAL_ENV := venv
VIRTUAL_BIN := $(VIRTUAL_ENV)/bin
PROJECT_NAME := easypost
TEST_DIR := tests

## help - Display help about make targets for this Makefile
help:
	@cat Makefile | grep '^## ' --color=never | cut -c4- | sed -e "`printf 's/ - /\t- /;'`" | column -s "`printf '\t'`" -t

## black - Runs the Black Python formatter against the project
black:
	$(VIRTUAL_BIN)/black $(PROJECT_NAME)/ $(TEST_DIR)/

## black-check - Checks if the project is formatted correctly against the Black rules
black-check:
	$(VIRTUAL_BIN)/black $(PROJECT_NAME)/ $(TEST_DIR)/ --check

## build - Builds the project in preparation for release
build:
	$(VIRTUAL_BIN)/python -m build

## clean - Remove the virtual environment and clear out .pyc files
clean:
	rm -rf $(VIRTUAL_ENV) dist/ build/ *.egg-info/ .pytest_cache .mypy_cache
	find . -name '*.pyc' -delete

## coverage - Test the project and generate an HTML coverage report
coverage:
	$(VIRTUAL_BIN)/pytest --cov=$(PROJECT_NAME) --cov-branch --cov-report=html --cov-report=term-missing --cov-fail-under=87

## docs - Generates docs for the library
docs:
	$(VIRTUAL_BIN)/pdoc $(PROJECT_NAME) -o docs

## format - Runs all formatting tools against the project
format: black isort

## format-check - Checks if the project is formatted correctly against all formatting rules
format-check: black-check isort-check lint mypy

## install - Install the project locally
install:
	$(PYTHON_BINARY) -m venv $(VIRTUAL_ENV)
	$(VIRTUAL_BIN)/pip install -e ."[dev]"
	git submodule init
	git submodule update

## isort - Sorts imports throughout the project
isort:
	$(VIRTUAL_BIN)/isort $(PROJECT_NAME)/ $(TEST_DIR)/

## isort-check - Checks that imports throughout the project are sorted correctly
isort-check:
	$(VIRTUAL_BIN)/isort $(PROJECT_NAME)/ $(TEST_DIR)/ --check-only

## lint - Lint the project
lint:
	$(VIRTUAL_BIN)/flake8 $(PROJECT_NAME)/ $(TEST_DIR)/

## mypy - Run mypy type checking on the project
mypy:
	$(VIRTUAL_BIN)/mypy $(PROJECT_NAME)/ $(TEST_DIR)/

## publish - Publish the project to PyPI
publish:
	$(VIRTUAL_BIN)/twine upload dist/*

## release - Cuts a release for the project on GitHub (requires GitHub CLI)
# tag = The associated tag title of the release
release:
	gh release create ${tag} dist/*

## scan - Scans the project for security issues with Bandit
scan:
	$(VIRTUAL_BIN)/bandit -r $(PROJECT_NAME)

## test - Test the project
test:
	$(VIRTUAL_BIN)/pytest

.PHONY: help black black-check build clean coverage docs format format-check install isort isort-check lint mypy publish release scan test
