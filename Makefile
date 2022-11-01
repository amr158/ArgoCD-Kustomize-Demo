version=v1.5.3
clusterNamespace=argocd
gpg-path=resources/gpg-keys
gpg-fbs=8CC3DBB98A442086023F9766A5296C151AD0CA9E 4C70A838416441A4E5A476B46E17861CCB27B2FB
# include environment variables of gitops, it has credentials for sops azure service account keys 
# azure keys are required to encrypt/decrypt secret and credential files
# include ~/gitops.env
# export $(shell sed 's/=.*//' ~/gitops.env)

help:		## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


uninstall-argocd:	## uninstall Argocd cluster wide 
	kustomize build --enable_alpha_plugins  ./base/argocd  | kubectl delete -f -

install-argocd:	## install Argocd cluster wide 
	kubectl create ns argocd || true
	# kustomize edit set namespace cluster
	kustomize build --enable-alpha-plugins  base/argocd | kubectl apply -f -
# 	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

install-cluster: ## install Argocd main bootstrap application
	kubectl apply -f install/cluster-bootstrap.yaml -n argocd

get-argocd-password: ## get the name pod name of argocd-server deployment
	# in version < 1.8
	# kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
	# get password for version > 1.9
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

get-influxdb-password: ## get the name pod name of argocd-server deployment
	# in version < 1.8
	# kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
	# get password for version > 1.9
	kubectl -n tick get secret tick-influxdb2-auth -o jsonpath="{.data.admin-token}" | base64 -d

download-argocd:	## ping all VMs in ibm cloud with root user
	kustomize build github.com/argoproj/argo-cd//manifests/cluster-install?ref=${version} > ./base/argocd/argocd_${version}.yaml

download-minio:		## download minio resource
	curl -sL https://raw.githubusercontent.com/minio/minio-operator/master/minio-operator.yaml -o ./base/minio/minio-operator.yaml
	curl -sL https://raw.githubusercontent.com/minio/minio-operator/master/examples/minioinstance.yaml -o ./base/minio/minioinstance-example.yaml


commons-ibm-all:	## install all required packages on all VMs, open-isci, iptables, ip utils
	ansible-playbook commons-playbook.yaml  -i inventory/hosts-ibm.yaml

wireguard-ibm-kube:	## isntall wireguard on all kube k3s servers
	# ./provision.sh
	ansible-playbook wireguard-playbook.yaml  -i inventory/hosts-ibm.yaml


gpg-export-public-keys:

	for key in 8CC3DBB98A442086023F9766A5296C151AD0CA9E  4C70A838416441A4E5A476B46E17861CCB27B2FB ; do \
	# for key in $(gpg-fps); do \
		echo "exporting $$key" ;\
		# gpg --output mygpgkey_sec.gpg --armor --export $(key) > ./$(gpg-path)/"$(key).pub"; \
		gpg --output mygpgkey_sec.gpg --armor --export $(key) --output "$(gpg-path)/$$key"; \
		echo "exported $(key)"; \
	done;

gpg-import-public-keys:
	echo "files $(shell ls ./resources/gpg-keys)"
	for key in $(shell ls ./resources/gpg-keys);  do \
		echo "importing $$key"; \
		gpg --import ./resources/gpg-keys/$$key; \
	done
	
