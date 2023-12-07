## First-time setup

### Pre-requisites

- Make sure you've installed NodeJS version. You can see the version in the `nvmrc` file
- You can also install [nvm](https://github.com/nvm-sh/nvm) in order to switch between different node versions
- Set yarn to install internal packages

### Install dependencies

Install all necessary dependencies via:

```bash
yarn
```

### Build and lint

You can build the project running

```bash
yarn build
```

And check the linter

```bash
yarn lint
```

### Copy profile configuration

Copy the local profile configuration via:

```bash
yarn setup:dev
```

This will leave you with a `local.js` file within the `config` folder that will be used as the profile configuration.
