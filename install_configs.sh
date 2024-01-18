#!/bin/bash

CONFIG_PATH="${HOME}/.config"
CWD=`pwd`

echo "Installing configs to [${CONFIG_PATH}]"

ln --symbolic --force "${CWD}/starship.toml" "${CONFIG_PATH}/starship.toml" 