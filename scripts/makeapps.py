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

ARCHIVE_EXT = [".tar.gz", ".tar.xz", ".zip"]

BUILD_DIR = Path("build/sources")
PATCH_DIR = Path("patches")
CONFIG_DIR = Path("configs")
OUTDIR = "build/apps"
HASHES_FILE = "hashes.txt"

def check_options(name, options, *attrs):
    missing_attrs = [attr for attr in attrs if attr not in options]
    if missing_attrs:
        sys.stderr.write(f"Missing attribute(s) in `{name}`: {', '.join(missing_attrs)}\n")
        exit(1)


def read_existing():
    filename = BUILD_DIR / HASHES_FILE
    if not os.path.exists(filename):
        return {}

    with open(filename) as file:
        return {line.split(' ')[0]: line.split(' ')[1].strip() for line in file}


def download(name, url):
    for ext in ARCHIVE_EXT:
        if url.endswith(ext):
            destname = BUILD_DIR / "archives" / f"{name}{ext}"
            print(f"Downloading `{url}` to `{destname}`")
            try:
                urllib.request.urlretrieve(url, destname)
            except urllib.error.HTTPError as err:
                sys.stderr.write(f"Unable to download: {err}\n")
                exit(1)
            return destname

    sys.stderr.write("Provided file is not a common archive\n")
    exit(1)


def optionhash(name, options):
    sha = hashlib.sha1()
    sha.update(name.encode())
    sha.update(json.dumps(options, sort_keys=True).encode())
    if 'config' in options:
        with open(CONFIG_DIR / options['config'], 'rb') as config:
            hashlib.file_digest(config, lambda: sha)
    for patchpath in options.get('patches', []):
        with open(PATCH_DIR / patchpath, 'rb') as patch:
            hashlib.file_digest(patch, lambda: sha)
    return sha.hexdigest()


def unpack(archive, name):
    ardir = BUILD_DIR / name
    shutil.rmtree(ardir, ignore_errors=True)

    tempdir = tempfile.mkdtemp()
    shutil.unpack_archive(archive, tempdir)

    items = os.listdir(tempdir)
    if len(items) == 1 and os.path.isdir(join(tempdir, items[0])):
        shutil.move(join(tempdir, items[0]), ardir)
    else:
        shutil.move(tempdir, ardir)

    shutil.rmtree(tempdir, ignore_errors=True)


def patch(name, diff):
    directory = BUILD_DIR / name
    rel = os.path.relpath(PATCH_DIR / diff, directory)
    print(f"patching {diff}")
    subprocess.run(['patch', '-p1', '-i', rel], check=True, cwd=directory)


def validate_checksum(dest, expected_checksum):
    with open(dest, 'rb') as file:
        actual_checksum = hashlib.file_digest(file, 'sha1').hexdigest()
    if actual_checksum != expected_checksum:
        sys.stderr.write(f"Invalid checksum:\n  Expected: {expected_checksum}\n  Got:      {actual_checksum}\n")
        exit(1)


def process_program(name, options, existing, db):
    check_options(name, options, "url", "checksum", "install")
    opthash = optionhash(name, options)

    if name in existing and existing[name] == opthash:
        print(f"Skipping `{name}`, already exists")
        db.write(f"{name} {opthash}\n")
        return

    os.makedirs(BUILD_DIR / "archives", exist_ok=True)

    archive_path = download(name, options['url'])
    validate_checksum(archive_path, options['checksum'])
    unpack(archive_path, name)

    if 'config' in options:
        shutil.copy(CONFIG_DIR / options['config'], BUILD_DIR / name / 'config.h')

    for patch_file in options.get('patches', []):
        patch(name, patch_file)

    db.write(f"{name} {opthash}\n")
    db.flush()

    subprocess.run(options['install'], shell=True, check=True, cwd=BUILD_DIR / name)


def main():
    if len(sys.argv) < 2:
        sys.stderr.write("Usage: makeapps.py [-f] <programs.yml>\n")
        exit(1)

    force = sys.argv[1] == '-f'
    if force:
        sys.argv.pop(1)

    with open(sys.argv[1]) as file:
        apps = yaml.safe_load(file)

    os.makedirs(BUILD_DIR, exist_ok=True)

    existing = {}
    if not force:
        existing = read_existing()

    os.environ["out"] = os.getcwd() + "/" + OUTDIR
    with open(BUILD_DIR / HASHES_FILE, "w") as db:
        for name, options in apps.items():
            process_program(name, options, existing, db)


if __name__ == "__main__":
    main()

