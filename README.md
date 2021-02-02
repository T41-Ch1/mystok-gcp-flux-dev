# mystok-gcp-flux-dev
起動手順:

1.
kubesec decrypt kubesec-dev-mystok-gcp-sealedsecret-cert.yaml | k apply -f -

2.
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.6/controller.yaml

3.

kubernetes current-contextをprod用から変える必要があるかも
k config use-context gke_vertical-reason-166903_us-central1_mystok-gcp-dev-cluster

flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --repository=mystok-gcp-flux-dev \
  --branch=main \
  --path=clusters/my-cluster \
  --token-auth \
  --personal

(作成時のみ)
flux create kustomization mystok-gcp-flux-dev \\n  --source=flux-system \\n  --path="." \\n  --prune=true \\n  --validation=client \\n  --interval=5m \\n  --export > ./clusters/my-cluster/mystok-gcp-flux-dev-kustomization.yaml

(作成時のみ)
flux create image repository mystok-gcp-flux-dev \\n--image=dekabitasp/mystok-gcp-app-dev \\n--interval=1m \\n--export > ./clusters/my-cluster/mystok-gcp-flux-dev-registry.yaml

(作成時のみ)
flux create image policy mystok-gcp-flux-prod \                                                                                                             ─╯
--image-ref=mystok-gcp-flux-prod \
--interval=1m \
--semver=5.0.x \
--export > ./clusters/my-cluster/mystok-gcp-flux-prod-policy.yaml    

(作成時のみ)
flux create image update flux-system \
--git-repo-ref=flux-system \
--branch=main \
--author-name=fluxcdbot \
--author-email=fluxcdbot@users.noreply.github.com \
--commit-template="[ci skip] update image" \
--export > ./clusters/my-cluster/flux-system-automation.yaml

gcloud config configulations activate でprod用から切り替える必要があるかも


3.
gcloud compute backend-services update k8s-be-31942--4739945ebad3cc4a --session-affinity=CLIENT_IP --global

4.
gcloud compute backend-services update k8s1-4739945e-default-mystok-app-80-34f883e2 --session-affinity=CLIENT_IP --global

5.
gcloud compute url-maps import web-map-http-dev --source ./gcloud/web-map-http-dev.yaml --global

6.
 gcloud compute target-http-proxies create http-lb-proxy-dev --url-map=web-map-http-dev --global

7.
gcloud compute forwarding-rules create http-content-rule-dev --address=mystok-gcp-ip-dev --global --target-http-proxy=http-lb-proxy-dev --ports=80

8.
gcloud consoleで操作

