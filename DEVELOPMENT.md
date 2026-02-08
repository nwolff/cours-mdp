# Locally

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
