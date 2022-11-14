#!/bin/bash

export PROJECT_ID="tidy-rainfall-367615" 

gcloud iam service-accounts create "coreinfra" \
  --project "${PROJECT_ID}"

gcloud services enable iamcredentials.googleapis.com \
  --project "${PROJECT_ID}"

gcloud iam workload-identity-pools create "coreinfra" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="Core infrastructure"

workload_identity_pool_id=$(gcloud iam workload-identity-pools describe "coreinfra" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --format="value(name)")

export WORKLOAD_IDENTITY_POOL_ID=$workload_identity_pool_id

gcloud iam workload-identity-pools providers create-oidc "gh-oidc" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="coreinfra" \
  --display-name="GH Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

export REPO="fardarter/gcp-core-infra"

gcloud iam service-accounts add-iam-policy-binding "coreinfra@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

gcloud iam workload-identity-pools providers describe "gh-oidc" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="coreinfra" \
  --format="value(name)"