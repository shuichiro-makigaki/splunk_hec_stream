workflow "tox" {
  resolves = [
    "GitHub Action for Docker",
    "GitHub Action for Docker-1",
  ]
  on = "push"
}

action "Filters for GitHub Actions" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "GitHub Action for Docker" {
  uses = "home-assistant/actions/py37-tox@master"
  needs = ["Filters for GitHub Actions"]
  args = "-e py37"
}

action "GitHub Action for Docker-1" {
  uses = "home-assistant/actions/py36-tox@master"
  needs = ["Filters for GitHub Actions"]
  args = "-e py36"
}
