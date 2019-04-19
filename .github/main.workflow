workflow "Tox" {
  resolves = [
    "Tox - Python 3.7",
    "Tox - Python 3.6",
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
