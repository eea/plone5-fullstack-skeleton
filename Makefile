MAKEFLAGS += --no-print-directory

.DEFAULT_GOAL := help

SHELL := /bin/bash

image-name-split = $(firstword $(subst :, ,$1))

SKELETON := "https://github.com/eea/plone5-fullstack-skeleton.git"

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

docker-compose.override.yml:
	@if [ ! -f 'docker-compose.override.yml' ]; then
		$(error "You need to run a setup recipe first")
	fi

.PHONY: init-submodules
init-submodules:
	git submodule init; \
	git submodule update; \
	@if [ -d "${FRONTEND}" ]; then \
		cd ${FRONTEND}; \
		make init-submodules
	else \
		echo "No frontend folder"; \
	fi; \

plone-data:
	sudo mkdir -p plone-data/filestorage
	sudo mkdir -p plone-data/zeoserver
	@echo "Setting data permission to uid 500"
	sudo chown -R 500 plone-data

ifeq "$(wildcard ${docker-compose.override.yml})" ""
HAS_PLONE_OVERRIDE := "$(shell cat docker-compose.override.yml | grep plone-data)"
endif

ifeq "$(wildcard ${docker-compose.override.yml})" ""
HAS_FRONTEND_OVERRIDE := "$(shell cat docker-compose.override.yml | grep frontend)"
endif

.skel:
	git clone $(SKELETON) .skel

.PHONY: plone_override
plone_override:.skel
	@if [ -z $(HAS_PLONE_OVERRIDE) ]; then \
		echo "Overwriting the docker-compose.override.yml file!"; \
		cp .skel/tpl/docker-compose.override.plone.yml docker-compose.override.yml; \
	fi

.PHONY: plone_install
plone_install:plone-data
	mkdir -p src
	sudo chown -R 500 src
	docker-compose up -d plone
	docker-compose exec plone gosu plone bin/develop rb
	docker-compose exec plone gosu plone /docker-initialize.py
	docker-compose exec plone gosu plone bin/instance adduser admin admin
	sudo chown -R `whoami` src/

.PHONY: setup-backend-dev
setup-backend-dev:plone_override plone_install 		## Setup needed for developing the backend
	rm -rf .skel

.PHONY: frontend_override
frontend_override:.skel
	@if [ -z $(HAS_FRONTEND_OVERRIDE) ]; then \
		echo "Overwriting the docker-compose.override.yml file!"; \
		cp .skel/tpl/docker-compose.override.frontend.yml docker-compose.override.yml; \
	fi;

.PHONY: frontend_install
frontend_install:
	docker-compose up -d frontend
	docker-compose exec frontend npm install

.PHONY: setup-frontend-dev
setup-frontend-dev:frontend_override frontend_install		## Setup needed for developing the frontend
	rm -rf .skel

.PHONY: fullstack_override
fullstack_override:.skel
	@if [ -z "$(HAS_PLONE_OVERRIDE)" ]; then \
		if [ -z "$(HAS_FRONTEND_OVERRIDE)" ]; then \
			echo "Overwriting the docker-compose.override.yml file!"; \
			cp .skel/tpl/docker-compose.override.fullstack.yml docker-compose.override.yml; \
		fi; \
	fi;

.PHONY: setup-fullstack-dev
setup-fullstack-dev:fullstack_override plone_install frontend_install		## Setup a fullstack developer
	rm -rf .skel

.PHONY: start-plone
start-plone:docker-compose.override.yml		## Start the plone process
	docker-compose stop plone
	docker-compose up -d plone
	docker-compose exec plone gosu plone /docker-initialize.py
	docker-compose exec plone gosu plone bin/instance fg

.PHONY: start-volto
start-volto:docker-compose.override.yml		## Start the frontend with Hot Module Reloading
	docker-compose up -d frontend
	docker-compose exec frontend npm run start

.PHONY: stop
stop:		## Stop all services
	docker-compose stop

.PHONY: start-volto-production
start-volto-production:docker-compose.override.yml		## Start the frontend service in production mode
	docker-compose up -d frontend
	docker-compose exec frontend make build
	docker-compose exec frontend yarn start:prod

.PHONY: volto-shell
volto-shell:docker-compose.override.yml		## Start a shell on the frontend service
	docker-compose up -d frontend
	docker-compose exec frontend bash

.PHONY: plone-shell
plone-shell:docker-compose.override.yml		## Start a shell on the plone service
	docker-compose up -d plone
	docker-compose exec plone gosu plone /docker-initialize.py
	docker-compose exec plone bash

.PHONY: release-frontend
release-frontend:		## Make a Docker Hub release for frontend
	set -e;\
		cd $(FRONTEND); \
		make release

.PHONY: release-backend
release-backend:		## Make a Docker Hub release for the Plone backend
	set -e; \
		cd $(BACKEND); \
		make release

.PHONY: build-backend
build-backend:		## Just (re)build the backend image
	set -e; \
		cd $(BACKEND); \
		make build-image

.PHONY: build-frontend
build-frontend:		## Just (re)build the frontend image
	set -e; \
		cd $(FRONTEND); \
		make build-image

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
		cp .skel/_frontend/Makefile ./frontend/; \
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
