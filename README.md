# Application stockage de mot de passe

https://mdp.nwolff.info/

Est un alias pour :

https://cours-mdp-5563464620.europe-west1.run.app/

# Developing Locally

The project uses [uv](https://docs.astral.sh/uv/) to manage Python and dependencies.

## Install dependencies

    uv sync

This creates `.venv/` and installs runtime + dev dependencies pinned in `uv.lock`.

## Run the app

    uv run python main.py

Then open <http://localhost:8080/>. The Flask dev server reloads on file changes.

## Run the tests

    uv run pytest

## Database

Either import storage.sqlite instead of storage.firestore

Or configure credentials on your local machine to connect to firestore :

    gcloud config set project cours-mdp-407714
    gcloud auth application-default login

Ref: https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev

## Tooling

To edit templates in vs-code:

- install better-jinja
- configure "associations" settings, .j2 should be mapped to jinja-html

# In production

## Runtime

Runs on Google Cloud Run (made to run containers)

## Database

Google Firestore

## Build

Google Cloud Build monitors the Github repository and deploys automatically upon pushes to main
