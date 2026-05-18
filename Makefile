release_name = argocd
namespace = argocd

install:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm install $(release_name) argo/argo-cd \
		--namespace $(namespace) \
		--create-namespace \
		--set controller.resources.limits.memory=2Gi \
		--set repoServer.resources.limits.memory=2GI \
		--set server.service.type=NodePort \
		--set global.logging.level=info \
		--set controller.replicas=1 \
		--set repoServer.replicas=1 \
		--set server.extraArgs='{--insecure}' \
		--set configs.params."server.disable.auth"=false
	kubectl wait deployment \
		--namespace $(namespace) \
		argocd-server \
		--for condition=Available=True \
		--timeout=600s
	kubectl apply -f bootstrap/root-app.yaml

uninstall:
	-helm uninstall $(release_name) \
		--namespace $(namespace)
	-helm repo remove argo


getpw:
	kubectl -n $(namespace) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo

ui: getpw
	kubectl port-forward \
		--address 0.0.0.0 \
		svc/argocd-server \
		--namespace $(namespace) 8080:443

cat:
	find . -path './.git' -prune -o -type f -exec sh -c 'for f do echo "--- $$f ---"; cat "$$f"; echo ""; done' _ {} +

kind-up:
	kind create cluster --config bootstrap/kind-config.yaml

kind-down:
	kind delete cluster
