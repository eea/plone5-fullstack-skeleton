# Volto-based generic fullstack skeleton

A place to put common files used to develop Plone 5 + Volto based projects.

The idea is to have a central place of useful code and configuration that can
provide a uniform developing experience.

## Getting started on a new project

1. Create your empty repo, publish it to github
2. (Optional) Add a `frontend` folder as a submodule
3. Add the skeleton files, using:

```sh
curl https://raw.githubusercontent.com/eea/plone5-fullstack-skeleton/master/setup.sh | bash -s
```

You can now run `make help` to see the recipes that you have available.

Each developer that will work on the project needs to execute, once they clone your development repo, one of the following bootstraps, according to their role:

- backend, run `make setup-plone-dev`
- frontend, run `make setup-frontend-dev`
- fullstack, run `make setup-fullstack-dev`. This executes both previous bootstraps and enables developing for both frontend and backend targets.

### Developing for the backend

The backend boostrap process creates the `src` folder where the Plone development packages are. Some useful commands are:

- `make start-plone` to start the Plone process
- `make plone-shell` to start a Plone docker container shell. This can be used to start the Plone instance manually, to debug code, or to rebuild the docker container buildout
- `make release-backend` to release a new version of the Plone docker image.

### Developing for the frontend

The frontend development part is optional. Not all repositories using this skeleton need to have a Volto-powered backend. The frontend is developed in the `frontend` folder. Some useful commands:

- `make start-volto` to start a hot-module reload enabled Volto
- `make volto-shell` to start a shell inside the Volto container
- `make release-frontend` to release a new version of the Volto (frontend) docker image.

## Keep your project updated to the common skeleton

To keep up to date with it run:

```
make sync-makefiles
```
