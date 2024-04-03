#!/bin/bash

set -e

DIRNAME=$(dirname "$0")

# SSH setup
SSH_DIR="$HOME/.ssh"
SSH_TYPE="ed25519"
SSH_PASS=""

# Ansible setup
ANSIBLE_REPOSITORY="ppa:ansible/ansible"
ANSIBLE_DIR="${DIRNAME}/../ansible"
ANSIBLE_MAIN_PLAYBOOK="main.ansible.yaml"

PYTHON_VERSION="python3.12"
PYTHON_REPOSITORY="ppa:deadsnakes/ppa"
VENV_DIR="${DIRNAME}/../.venv"
REQUIREMENTS_PATH="${ANSIBLE_DIR}/requirements.txt"

echo "Running setup script..."

function ensureAnsible(){
    if [ -x "$(command -v ansible)" ]
    then
        echo "[+] Ansible installed"
    else
        echo "[-] Ansible not found, installing..."

        sudo apt-add-repository -y "${ANSIBLE_REPOSITORY}"
        sudo apt update
        sudo apt install -y ansible
    fi
}

function setupPythonForAnsible(){
    # ensure python installation
    if [ -x "$(command -v ${PYTHON_VERSION})" ]
    then
        echo "[+] Python [${PYTHON_VERSION}] installed"
    else
        echo "[-] Python [${PYTHON_VERSION}] not found, installing..."
        sudo add-apt-repository ppa:deadsnakes/ppa --yes
        sudo apt update
        sudo apt install ${PYTHON_VERSION} ${PYTHON_VERSION}-venv
    fi
    # ensure venv created
    if [ -d "${VENV_DIR}" ]
    then
        echo "[+] Python venv already present"
    else
        echo "[-] Python venv not found, creating..."
        ${PYTHON_VERSION} -m venv "${VENV_DIR}"
    fi
    # ensure requirements installed
    echo "[x] Ensuring requirements are installed..."
    source "${VENV_DIR}/bin/activate"
    pip3 install -qr "${REQUIREMENTS_PATH}"
}

function ensureAnsibleRequirements(){
    echo "[x] Getting all requirements from Ansible..."
    ansible-galaxy install -r "${ANSIBLE_DIR}/requirements.yaml"
}

function runAnsiblePlaybooks(){
    echo "[x] Running Ansible playbooks..."
    # running it with sudo instead of -K
    # would be less annoying, however
    # running it with sudo somehow fucks things up
    # so here we are
    ansible-playbook "${ANSIBLE_DIR}/${ANSIBLE_MAIN_PLAYBOOK}" -K
}

function createSSHKey(){
    local filename=$1
    ssh-keygen -t "${SSH_TYPE}" -f "${filename}" -N "${SSH_PASS}" -C "$USER/$HOSTNAME"
    chmod 600 "${$1}"
}

function setupSSH(){
    mkdir -p "${SSH_DIR}"
    chmod 700 "${SSH_DIR}"
    local ID_FILE="${SSH_DIR}/id_${SSH_TYPE}"
    if [ -f "${ID_FILE}" ]
    then
        echo "[+] SSH id key already exists"
    else
        echo "[-] Generating new SSH id file with type [${SSH_TYPE}]"
        createSSHKey "${ID_FILE}"
        cat "${ID_FILE}.pub" >> "${SSH_DIR}/authorized_keys"
        chmod 600 "${SSH_DIR}/authorized_keys"
    fi
    local VCS_FILE="${SSH_DIR}/vcs"
    if [ -f "${VCS_FILE}" ]
    then
        echo "[+] VCS ssh key already exists"
    else
        echo "[-] Generating new VCS SSH key with type [${SSH_TYPE}]"
        createSSHKey "${VCS_FILE}"
        echo "IdentityFile ${VCS_FILE}" >> "${SSH_DIR}/config"
        chmod 600 "${SSH_DIR}/config"
    fi
}

setupPythonForAnsible
ensureAnsible
setupSSH
ensureAnsibleRequirements
runAnsiblePlaybooks
