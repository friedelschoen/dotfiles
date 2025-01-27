#!/usr/bin/env python3

import yaml
import sys
import os
import urllib.request
import tempfile
import shutil
import hashlib
import json
import subprocess
from os.path import join
from pathlib import Path

OUTDIR_DIR = Path("build/service")

def check_options(name, options, *attrs):
    missing_attrs = [attr for attr in attrs if attr not in options]
    if missing_attrs:
        sys.stderr.write(f"Missing attribute(s) in `{name}`: {', '.join(missing_attrs)}\n")
        exit(1)

def make_service(name, options):
    check_options(name, options, "run")

    os.makedirs(OUTDIR_DIR / name, exist_ok=True)

    with open(OUTDIR_DIR / name / 'run', 'w') as runfile:
        runfile.write(options['run'])

    os.chmod(OUTDIR_DIR / name / 'run', 0o775)

    if 'finish' in options:
        with open(OUTDIR_DIR / name / 'finish', 'w') as finishfile:
            finishfile.write(options['finish'])
        os.chmod(OUTDIR_DIR / name / 'finish', 0o775)
    else:
        try: 
            os.remove(OUTDIR_DIR / name / 'finish')
        except FileNotFoundError: pass

    if options.get('enabled', True):
        try: 
            os.remove(OUTDIR_DIR / name / 'down')
        except FileNotFoundError: pass
    else:
        with open(OUTDIR_DIR / name / 'down', 'w') as downfile:
            pass


def main():
    if len(sys.argv) < 2:
        sys.stderr.write("Usage: makeservices <services.yml>\n")
        exit(1)

    with open(sys.argv[1]) as file:
        services = yaml.safe_load(file)

    for name, options in services.items():
        make_service(name, options)

if __name__ == "__main__":
    main()
