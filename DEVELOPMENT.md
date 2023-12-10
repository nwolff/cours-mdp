# Locally

Either import storage.sqlite instead of storage.firestore

Or configure credentials on your local machine to connect to firestore :
https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev

# In production

## Runtime

Runs on Google Cloud Run (made to run containers)

## Database

Google Firestore

## Build

Google Cloud Build monitors the Github repository and deploys automatically upon pushes to main
