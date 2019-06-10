workflow "Test on push" {
  resolves = [
    "Tox - Python 3.6",
    "Tox - Python 3.7",
    "Terraform validate",
  ]
  on = "push"
}

action "Filter branch master" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Tox - Python 3.7" {
  uses = "home-assistant/actions/py37-tox@master"
  args = "-e py37"
  needs = ["Filter branch master"]
}

action "Tox - Python 3.6" {
  uses = "home-assistant/actions/py36-tox@master"
  args = "-e py36"
  needs = ["Filter branch master"]
}

workflow "Test on pull request" {
  resolves = [
    "Tox - Python 3.7",
    "Tox - Python 3.6",
    "Terraform validate"
  ]
  on = "pull_request"
}

action "Terraform init" {
  uses = "hashicorp/terraform-github-actions/init@v0.3.1"
  needs = ["Filter branch master"]
  env = {
    TF_ACTION_WORKING_DIR = "./contrib/terraform"
  }
}

action "Terraform validate" {
  uses = "hashicorp/terraform-github-actions/validate@v0.3.1"
  needs = ["Terraform init"]
  env = {
    TF_ACTION_WORKING_DIR = "./contrib/terraform"
  }
}
