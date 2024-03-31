# dot-config

This repo is supposed to hold a personal configuration of a workstation for easier setup of new machines or sync between different machines.

## Using the configs

In order to not clutter the repo/.gitignore with whatever files may be present in `~/.config` directory, the configs that are supposed to be tracked are created as links with the ansible.

To create the entire setup run

```bash
./bin/dotfiles.sh
```

> **NOTE:** currently there is no mechanism to undo/remove the create setup
