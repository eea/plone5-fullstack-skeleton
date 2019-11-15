# Volto/Plone-based generic fullstack development skeleton

A place to put common files used to develop Plone 5 + Volto based projects. 

The idea is to have a central place of useful code and configuration that can
provide a uniform developing experience. Stacks generated from this skeleton are not intended to be used in production, only for development. A production setup might be later provided as part of this skeleton.

## Getting started on a new project

1. Create your empty repo, publish it to github
2. (Optional) Add a `frontend` folder as a submodule
3. Add the skeleton files, using:

```sh
curl https://raw.githubusercontent.com/eea/plone5-fullstack-skeleton/master/setup.sh | bash -s
```

You can now run `make help` to see the recipes that you have available.

Each developer that will work on the project needs to execute (after they clone your development repo) one of the following bootstrap targets, according to their role:

- backend, run `make setup-plone-dev`
- frontend, run `make setup-frontend-dev`
- fullstack, run `make setup-fullstack-dev`. This executes both previous bootstraps and enables developing for both frontend and backend targets.

### Developing for the backend

The backend boostrap process creates the `src` folder where the Plone development packages are. Some useful commands are:

- `make start-plone` to start the Plone process
- `make plone-shell` to start a Plone docker container shell. This can be used to start the Plone instance manually, to debug code, or to rebuild the docker container buildout
- `make release-backend` to release a new version of the Plone docker image.

To create a new addon, you can run something like this: (please adjust according to intended package name and your user uid on the host machine - 1000 is usually the default on desktop Linux distributions, but there's no standard).

```
pip install bobtemplates.plone
mrbob bobtemplates.plone:addon -O src/eea.mynewpkg
cd src/eea.mynewpkg
mrbob bobtemplates.plone:content_type
cd -
chown -R 1000 src
```

The `backend/site.cfg` file is mapped as a docker volume. If you change this file, the plone container needs to be restarted:

```
make shell
docker-compose restart plone
```
If you brind new development packages, you need to fix permissions in the `src/` folder, by running (in bash):
```
sudo chown -R `whoami` src/
```

If you use fish as a shell, run:

```
sudo chown -R (whoami) src/
```

### Developing for the frontend

The frontend development part is optional. Not all repositories using this skeleton need to have a Volto-powered backend. The frontend is developed in the `frontend` folder. Some useful commands:

- `make start-volto` to start a hot-module reload enabled Volto
- `make volto-shell` to start a shell inside the Volto container
- `make release-frontend` to release a new version of the Volto (frontend) docker image.

When developing a new frontend addon, the end goal is to have it available standalone, as an npm released package. The "classic" option would be to run `npm link` inside the package, then link it inside the frontend node_modules with `npm link packagename`. This requires that you also transpile and bundle the code inside that package, usually achieved with webpack configured with babel loaders.

While that is possible, there's another simpler way available: have "volto" (actually volto's razzle/webpack/babel presets) compile that code and alias that module's path in volto. Volto documentation recommends `mr.developer` as a tool that, given a configuration file with package definitions, it can clone those packages in the `src/addons` folder. Then the `jsconfig.json`, `.eslintrc` and `package.json` files need to be adjusted to include aliases for the new addon package. 

To facilitate activating/deactivating these addon package, inside the `frontend` folder, run the following commands to activate and deactivate packages:

```
make activate pkg=<pkgname>
make deactivate pkg=<pkgname>
```
You then needs to restart the frontend server process.

### Troubleshooting

- `Bind for 0.0.0.0:8888 failed: port is already allocated`: you need to use another port for binding, see the `.env` file
- `sh: 1: razzle: not found` when trying to run `make start-volto`: you're probably started mapping the frontend folder to container, so you need to do:

```
make volto-shell
npm install
```

## Keep your project updated to the common skeleton

To keep up to date with it run:

```
make sync-makefiles
```
