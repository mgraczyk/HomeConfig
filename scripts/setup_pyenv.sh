#!/bin/bash
python_version="$(python3 -V 2>&1)"
required_python_version='Python 3.7'

if ! (echo $python_version | egrep "$required_python_version" >/dev/null); then
  echo "Incorrect python version: You have $python_version, you need $required_python_version"
else
  if [ -x "$(command -v virtualenv)" ]; then
    test -d .venv3/ || pyenv virtualenv .venv3 --venv-base-dir .
  else
    test -d .venv3/ || virtualenv .venv3 --python=python3
  fi
  source .venv3/bin/activate

  python -m pip install --upgrade pip
  PYCURL_SSL_LIBRARY=openssl python -m pip install -r requirements.txt
  export PYTHONPATH=$(pwd)
  test -f .env && source .env
fi
