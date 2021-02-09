#!/bin/bash
gcloud compute url-maps import web-map-http-dev --source ./gcloud/web-map-http-dev.yaml --global
gcloud compute target-http-proxies create http-lb-proxy-dev --url-map=web-map-http-dev --global
gcloud compute forwarding-rules create http-content-rule-dev --address=mystok-gcp-ip-dev --global --target-http-proxy=http-lb-proxy-dev --ports=80
