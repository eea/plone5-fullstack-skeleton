.DEFAULT_GOAL := help

SHELL := /bin/bash

image-name-split = $(firstword $(subst :, ,$1))

SKELETON := "https://github.com/tiberiuichim/fullstack-skeleton.git"

# identify project folders
BACKEND := backend
FRONTEND := frontend

BACKEND_DOCKERIMAGE_FILE := "${BACKEND}/docker-image.txt"
export BACKEND_IMAGE := $(shell cat $(BACKEND_DOCKERIMAGE_FILE))
BACKEND_IMAGE_NAME := $(call image-name-split,$(BACKEND_IMAGE))

ifneq "$(wildcard ${FRONTEND}/.)" ""
	FRONTEND_DOCKERIMAGE_FILE := "${FRONTEND}/docker-image.txt"
	export FRONTEND_IMAGE := $(shell cat $(FRONTEND_DOCKERIMAGE_FILE))
	FRONTEND_IMAGE_NAME := $(call image-name-split,$(FRONTEND_IMAGE))
else
endif

.PHONY: bootstrap
bootstrap: init-submodules setup-data setup-plone
	@echo "bootstraping"

.PHONY: init-submodules
init-submodules:
	git submodule init; \
	git submodule update; \
	@if [ -d "${FRONTEND}" ]; then \
		cd ${FRONTEND}; \
		git submodule init; \
		git submodule update
	else \
		echo "No frontend folder"; \
	fi; \

.PHONY: setup-data
setup-data:		## Setup the datastorage for Zeo
	mkdir -p data/filestorage
	mkdir -p data/zeoserver
	@echo "Setting data permission to uid 500"
	sudo chown -R 500 data

.PHONY: setup-plone
setup-plone:		## Setup products folder and Plone user
	sudo chown -R 500 src
	docker-compose up -d
	docker-compose exec plone gosu plone bin/develop rb
	docker-compose exec plone gosu plone /docker-initialize.py
	docker-compose exec plone gosu plone bin/instance adduser admin admin
	sudo chown -R `whoami` src/

.PHONY: start-plone
start-plone:		## Start the plone process
	docker-compose stop plone
	docker-compose up -d zeo
	docker-compose up -d plone
	docker-compose exec plone gosu plone /docker-initialize.py
	docker-compose exec plone gosu plone bin/instance fg

.PHONY: start-frontend
start-frontend:		## Start the frontend with Hot Module Reloading
	docker-compose up -d frontend
	docker-compose exec frontend npm run start

.PHONY: frontend-shell
frontend-shell:		## Start a shell on the frontend service
	docker-compose up -d frontend
	docker-compose exec frontend bash

.PHONY: plone-shell
plone-shell:		## Start a shell on the plone service
	docker-compose up -d plone
	docker-compose exec plone bash

.PHONY: start-frontend-production
start-frontend-production:		## Start the frontend service in production mode
	docker-compose up -d frontend
	docker-compose exec frontend make build
	docker-compose exec frontend yarn start:prod

.PHONY: release-frontend
release-frontend:		## Make a Docker Hub release for frontend
	set -e;\
		cd $(FRONTEND); \
		&& make release

.PHONY: release-plone
release-plone:		## Make a Docker Hub release for the Plone backend
	set -e; \
		cd $(BACKEND); \
		make release

.PHONY: eslint
eslint:		## Run eslint --fix on all *.js, *.json, *.jsx files in src
	set -e; \
		cd ${FRONTEND};\
		echo "Linting JS files";\
		eslint --fix src/**/*.js;\
		echo "Linting JSX files";\
		eslint --fix src/**/*.jsx
		echo "Linting JSON files";\
		eslint --fix src/**/*.json;

.PHONY: clean-releases
clean-releases:		## Cleanup space by removing old docker images
	sh -c "docker images | grep ${BACKEND_IMAGE_NAME} | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi ${BACKEND_IMAGE_NAME}:{}"
	sh -c "docker images | grep ${FRONTEND_IMAGE_NAME} | tr -s ' ' | cut -d ' ' -f 2 | xargs -I {} docker rmi ${FRONTEND_IMAGE_NAME}:{}"

.PHONY: sync-makefiles
sync-makefiles:		## Updates makefiles to latest github versions
	@rm -rf ./.skel
	@git clone ${SKELETON} .skel
	@cp .skel/Makefile ./
	@cp .skel/backend/Makefile ./backend/Makefile
	@if [ -d "${FRONTEND}" ]; then \
		cp .skel/frontend/Makefile ./frontend/; \
	else \
		echo "No frontend folder"; \
	fi; \
	rm -rf ./.skel

.PHONY: sync-dockercompose
sync-dockercompose:		## Updates docker-compose.yml to latest github versions
	git clone ${SKELETON} .skel
	cp .skel/docker-compose.yml ./
	rm -rf ./.skel

.PHONY: shell
shell:		## Starts a shell with proper env set
	$(SHELL)

.PHONY: help
help:		## Show this help.
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"
