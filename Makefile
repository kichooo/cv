# -----------------------------------------------------------------------------
# BUILD
# dependencies: moderncv, pdflatex, texlive-fonts-extra
# -----------------------------------------------------------------------------
.PHONY: all
all: prepare_volume_local pdf open destroy_volume

.PHONY: bootstrap
bootstrap:
	cp .env.local .env

.PHONY: pdf
pdf:
	@docker run -w /data --volumes-from data nilrecurring/latex-gfonts pdflatex -jobname cv cv.tex

.PHONY: open
open:
	@xdg-open cv.pdf

.PHONY: local_plan
local_plan: create_account_file prepare_volume client_install client_test client_build gcloud_login init plan destroy_volume gcloud_destroy

.PHONY: local_destroy
local_destroy: create_account_file prepare_volume client_install client_test client_build gcloud_login init destroy destroy_volume gcloud_destroy

.PHONY: local_apply
local_apply: create_account_file prepare_volume client_install client_test client_build gcloud_login init plan apply client_upload destroy_volume gcloud_destroy

.PHONY: plan
plan:
	@docker run -w /data --volumes-from data --env-file .env -it hashicorp/terraform:0.11.3 plan -out plan

.PHONY: apply
apply:
	@docker run -w /data --volumes-from data -it hashicorp/terraform:0.11.3 apply -auto-approve "plan"

.PHONY: destroy
destroy:
	@docker run -w /data --volumes-from data --env-file .env -it hashicorp/terraform:0.11.3 destroy -force

.PHONY: init
init:
	@docker run -w /data --volumes-from data --env-file .env -it --entrypoint "" hashicorp/terraform:0.11.3 sh -c 'terraform init -backend-config="prefix=$${TF_VAR_ENV}"'

.PHONY: create_account_file
create_account_file:
	@echo ${GOOGLE_CREDENTIALS_FILE} | base64 --decode  > account.json

.PHONY: prepare_volume
prepare_volume: destroy_volume
	@docker create -v /data --name data alpine:3.4 /bin/true
	@docker cp . data:/data

.PHONY: prepare_volume_local
prepare_volume_local: destroy_volume
	@docker create -v `pwd`:/data --name data alpine:3.4 /bin/true

.PHONY: destroy_volume
destroy_volume:
	@-docker rm -f data

.PHONY: client_install
client_install:
	docker run -w /data/client --volumes-from data -it node:9.9.0-alpine yarn install

.PHONY: client_build
client_build:
	docker run -w /data/client --volumes-from data -it node:9.9.0-alpine yarn build

.PHONY: client_test
client_test:
	docker run -w /data/client --volumes-from data --env-file .env -it node:9.9.0-alpine yarn test

.PHONY: client_upload
client_upload:
	docker run -w /data --volumes-from data --volumes-from gcloud-config --env-file .env -it --entrypoint "" google/cloud-sdk:193.0.0-alpine sh -c 'gsutil -m -h Cache-Control:private cp -R client/build/* gs://$${TF_VAR_DOMAIN}'
	docker run -w /data --volumes-from data --volumes-from gcloud-config --env-file .env -it --entrypoint "" google/cloud-sdk:193.0.0-alpine sh -c 'gsutil -h Cache-Control:private cp -R cv.pdf gs://$${TF_VAR_DOMAIN}'

.PHONY: gcloud_login
gcloud_login:
	docker run -w /data --volumes-from data -it --name gcloud-config google/cloud-sdk:193.0.0-alpine gcloud auth activate-service-account --key-file account.json

.PHONY: gcloud_destroy
gcloud_destroy:
	docker rm -f gcloud-config