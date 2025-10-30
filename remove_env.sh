#!/bin/bash
# read the environment variables from my_env.env file
source my_env.env
echo "Conda Env Name: $MY_PYTHON_VIRTURL_ENV_NAME"
# read current directory path
CURRENT_DIR=$(pwd)
echo "Current Directory: $CURRENT_DIR"
# create a python virtual environment install directory
VENV_DIR="./$MY_PYTHON_VIRTURL_ENV_NAME"
VENV_NAME="$CURRENT_DIR/$MY_PYTHON_VIRTURL_ENV_NAME"
echo "Virtual Environment Directory: $VENV_DIR"
echo "Virtual Environment Name: $VENV_NAME"
# --------------------------------------------------------------
# check the $VENV_NAME conda environment is activated
if [ "$CONDA_DEFAULT_ENV" == "$VENV_NAME" ]; then
    echo "🔥🔥🔥Deactivating the virtual environment..."
fi
# --------------------------------------------------------------
# check the $venv_dir directory exists
if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment directory already exists.🔥🔥🔥"
    # remove the virtual environment
    conda env remove --prefix $VENV_NAME -y
fi