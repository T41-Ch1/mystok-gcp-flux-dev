# mystok-gcp-flux-dev
#Caution:
#devとdevを同時に起動しようとするとバグるので、dev起動次第devを起動する
#gcloud config configulations activateで切り替えが必要かも
#k config use-context YOUR_CONTEXT_NAMEで障害時に対象クラスタの切り替えが必要かも

起動手順:

@前回起動したLBの削除確認&削除:
gcp consoleで行う

@NEGが溜まってないか確認&削除:
gcp consoleで行う

@mrtが溜まってないか確認&削除:
gcloud compute ssl-certificates list
gcloud compute ssl-certificates delete `gcloud compute ssl-certificates list | awk '{print $1}' | awk 'NR%2!=1'`

@TerraformでGKE等を作成:
cd mystok-gcp-terraform/dev
terraform apply

@GKE認証:
gcloud container clusters get-credentials YOUR_CLUSTERNAME --region YOUR_REGION

@kubesecの鍵、本体、Fluxをk8sにデプロイ
./startup
#kubesec decrypt kubesec-dev-mystok-gcp-sealedsecret-cert.yaml | k apply -f -
#kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.6/controller.yaml
#flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --owner=$GITHUB_USER \
  --repository=mystok-gcp-flux-dev \
  --branch=main \
  --path=clusters/my-cluster \
  --token-auth \
  --personal

@(作成時のみ)
flux create kustomization mystok-gcp-flux-dev \\n  --source=flux-system \\n  --path="." \\n  --prune=true \\n  --validation=client \\n  --interval=5m \\n  --export > ./clusters/my-cluster/mystok-gcp-flux-dev-kustomization.yaml

@(作成時のみ)
flux create image repository mystok-gcp-flux-dev \                        ─╯
--image=dekabitasp/mystok-gcp-app-dev \
--interval=1m \
--export > ./clusters/my-cluster/mystok-gcp-flux-dev-registry.yaml

@(作成時のみ)
flux create image policy mystok-gcp-flux-dev \                                                                                                             ─╯
--image-ref=mystok-gcp-flux-dev \
--interval=1m \
--semver=5.0.x \
--export > ./clusters/my-cluster/mystok-gcp-flux-dev-policy.yaml

@You should modify manifest to disable semver and enable alphabetical order

 
@mcrt,ingressがエラー吐いてないかチェック
k get mcrt
k get ing

@Enable Session Affinity:
gcloud compute backend-services list
gcloud compute backend-services update YOUR_FIRST_BACKEND --session-affinity=CLIENT_IP --global
gcloud compute backend-services update YOUR_SECOND_BACKEND --session-affinity=CLIENT_IP --global

@Enable HTTP Redirect:

cd mystok-gcp-flux-dev
./httpRedirect
#gcloud compute url-maps import web-map-http-dev --source ./gcloud/web-map-http-dev.yaml --global
#gcloud compute target-http-proxies create http-lb-proxy-dev --url-map=web-map-http-dev --global
#gcloud compute forwarding-rules create http-content-rule-dev --address=mystok-gcp-ip-dev --global --target-http-proxy=http-lb-proxy-dev --ports=80
gcp consoleでPrefix_Redirect=>Full_Path_Redirectに変更

