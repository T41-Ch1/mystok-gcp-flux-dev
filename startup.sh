#!/bin/zsh

#kubectl config use-context 

cd kubesec

kubesec decrypt kubesec-dev-mystok-gcp-sealedsecret-cert.yaml | kubectl apply -f -

kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.6/controller.yaml

flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --repository=mystok-gcp-flux-dev \
  --branch=main \
  --path=clusters/my-cluster \
  --token-auth \
  --personal

