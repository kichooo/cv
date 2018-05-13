include .env

# -----------------------------------------------------------------------------
# BUILD
# dependencies: moderncv, pdflatex, texlive-fonts-extra
# -----------------------------------------------------------------------------
.PHONY: all
all: pdf open

.PHONY: pdf
pdf:
	@docker run --rm -v `pwd`:/data nilrecurring/latex-gfonts pdflatex -jobname cv cv.tex

.PHONY: open
open:
	@xdg-open cv.pdf

.PHONY: clean
clean:
	@rm -f *.out *.log *.pdf *.aux

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
	@docker run -w /data --volumes-from data -it hashicorp/terraform:0.11.3 init -backend-config="prefix=${TF_VAR_ENV}"

.PHONY: create_account_file
create_account_file:
	@echo ${GOOGLE_CREDENTIALS_FILE} | base64 --decode  > account.json

.PHONY: prepare_volume
prepare_volume:
	@docker create -v /data --name data alpine:3.4 /bin/true
	@docker cp . data:/data

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
	docker run -w /data --volumes-from data --volumes-from gcloud-config -it google/cloud-sdk:193.0.0-alpine gsutil -h Cache-Control:private cp -R client/build/* gs://${TF_VAR_DOMAIN}

.PHONY: gcloud_login
gcloud_login:
	docker run -w /data --volumes-from data -it --name gcloud-config google/cloud-sdk:193.0.0-alpine gcloud auth activate-service-account --key-file account.json

.PHONY: gcloud_destroy
gcloud_destroy:
	docker rm -f gcloud-config