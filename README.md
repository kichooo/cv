# Curriculum Vitae (CV)

My personal cv in LaTeX

## Prerequisites

*   docker

## Create PDF

A simple `make bootstrap; make` should do the trick if you have docker installed.

Look at the [Makefile](Makefile) for more commands

## Run and develop client locally

You need yarn installed

```bash
cd client
yarn install
yarn start
```

## Deploy test version to google cloud

You need `account.json.backup` - json access key for google cloud service account.

```bash
export GOOGLE_CREDENTIALS_FILE=$( base64 account.json.backup | tr -d '\n' )
make bootstrap
make local_apply
```

And visit the website address, by default https://local.burlinski.info

## Special thanks

For [Martin Knoller Stocker](https://github.com/linuxswords) for open sourcing his cv repo.
