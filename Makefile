SHELL := bash
.DEFAULT_GOAL := up
.PHONY: clean validatehost down up

_UID := $(shell id -u)
_GID := $(shell id -g)
CONTAINER_USER := gitops
GIT_DIR := /home/$(CONTAINER_USER)/gitfetcher
HOST_DIR := $(HOME)/gitfetcher
#
# User Change These
#
REPO_URL := https://github.com/timblaktu/dockge-stacks.git
POLLING_INTERVAL_SECONDS := 5
# See ./README.md#secret-management for details on how this is used.
HOST_REPO_ACCESS_TOKEN_PATH := $(HOME)/repo_access_token.ONLY_READABLE_BY_ADMINS.txt
export

clean:
	rm compose.yml

compose.yml: compose.yml.envsubst
	envsubst '$${_UID} $${_GID} $${CONTAINER_USER} $${GIT_DIR} $${HOST_DIR} $${REPO_URL} $${POLLING_INTERVAL_SECONDS} $${HOST_REPO_ACCESS_TOKEN_PATH}' < compose.yml.envsubst > compose.yml
	@tail -vn99 compose.yml

up: compose.yml
	docker compose up -d

down: compose.yml
	docker compose down

validatehost:
	@printf "Validating Host Environment..\n"
	@printf "    Testing bash.. "
	@if ! command -v bash 2>&1 >/dev/null; then printf "$(RED)$(BOLD)✗  bash does not appear to be on your PATH!$(RESET)\n" && exit 1; else printf "$(GREEN)✓$(RESET)\n"; fi
	@printf "    Testing git.. "
	@if ! command -v git 2>&1 >/dev/null; then printf "$(RED)$(BOLD)✗  git does not appear to be on your PATH!$(RESET)\n"; exit 1; else printf "$(GREEN)✓$(RESET)\n"; if ! git config color.ui; then printf "        $(YELLOW)Required git option $(GREEN)color.ui$(YELLOW) is not set in host. Setting this now..$(RESET)\n"; git config --verbose color.ui true; fi; fi
	@printf "    Testing docker.. "
	@if ! command -v docker 2>&1 >/dev/null; then printf "$(RED)$(BOLD)✗  docker does not appear to be on your PATH!$(RESET)\n" && exit 1; else printf "$(GREEN)✓$(RESET)\n"; fi
	@printf "    Testing Bitbucket access.. "
	@if ! git clone -q git@bitbucket.org:xilica/tr.git $$(mktemp -d); then printf "$(RED)$(BOLD)✗  Failed cloning repo from bitbucket workspace!$(RESET)\n" && exit 1; else printf "$(GREEN)✓$(RESET)\n"; fi
	@printf "    Testing Azure Container Registry access.. "
	@. scripts/functions.sh && if ! crauth; then printf "$(RED)$(BOLD)✗  Failed to authenticate to Azure Container Registry. You will be forced to build containers locally.$(RESET)\n"; else printf "$(GREEN)✓$(RESET)\n"; fi
	@printf "$(GREEN)Host Environment was Validated at $(shell date)$(RESET)\n" | tee -a .validhostenv

