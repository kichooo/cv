variable "DOMAIN" {
  description = "Domain for the projects."
}

variable "ENV" {
  description = "Environment used for the setup."
}

provider "google" {
  project     = "krzysztof-burlinski-cv"
  region      = "us-central1"
  credentials = "${file("account.json")}"
}

terraform {
  backend "gcs" {
    project     = "krzysztof-burlinski-cv"
    bucket  = "tf-state-0"
    credentials = "account.json"
    region      = "europe-west3"
  }
}

resource "google_storage_bucket" "website" {
  name     = "${var.DOMAIN}"
  force_destroy = true
  location = "eu"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_default_object_acl" "website" {
  bucket = "${google_storage_bucket.website.name}"
  role_entity = [
    "READER:allUsers",
  ]
}