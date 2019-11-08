# Volto-based generic fullstack skeleton

A place to put common files used to develop Plone 5 + Volto based projects.

The idea is to have a central place of useful code and configuration that can
provide a uniform developing experience.

## Getting started on a new project

1. Create your empty repo, publish it to github
2. (Optional) Add a `frontend` folder as a submodule
3. Add the skeleton files, using:

```sh
curl https://raw.githubusercontent.com/eea/plone5-fullstack-skeleton/setup.sh | bash -
```

You can now run `make help` to see the recipes that you have available.

The recipe that you will use depend on your intended role in the project: as
a frontend or backend developer.

For backend developing, run the `make setup-plone-dev` command. For frontend
development, run `make setup-frontend-dev`. For fullstack developer, run `make
setup-fullstack-dev`.

## Keep your project updated to the common skeleton

To keep up to date with it run:

```
make sync-makefiles
```
