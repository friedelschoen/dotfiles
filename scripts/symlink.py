#!/usr/bin/env python3

import os
import sys
from pathlib import Path

def symlink_files(source_dir, target_dir):
    source_dir = Path(source_dir).resolve()
    target_dir = Path(target_dir).resolve()
    links_file = target_dir / ".home-links"

    if not source_dir.is_dir():
        print(f"Error: Source directory '{source_dir}' does not exist or is not a directory.")
        sys.exit(1)

    # Load existing links from the links file if it exists
    existing_links = set()
    if links_file.exists():
        with open(links_file, "r") as f:
            existing_links = set(line.strip() for line in f if line.strip())

    new_links = set()

    for root, _, files in os.walk(source_dir):
        for file in files:
            src = Path(root) / file
            rel_path = src.relative_to(source_dir)
            dest = target_dir / rel_path

            # Ensure parent directory exists for the destination
            dest.parent.mkdir(parents=True, exist_ok=True)

            if dest.exists():
                if dest.is_symlink() and os.readlink(dest) == str(os.path.relpath(src, dest.parent)):
                    print(f"Skipping existing symlink: {dest}")
                    new_links.add(str(rel_path))
                    continue
                else:
                    print(f"Error: {dest} exists and is not a symlink created by this script.")
                    sys.exit(1)

            print(f"Creating symlink: {dest} -> {os.path.relpath(src, dest.parent)}")
            dest.symlink_to(os.path.relpath(src, dest.parent))
            new_links.add(str(rel_path))

    new_links |= existing_links
    # Append new links to the .home-links file
    with open(links_file, "a") as f:
        for link in new_links:
            f.write(link + "\n")


def remove_links(target_dir):
    target_dir = Path(target_dir).resolve()
    links_file = target_dir / ".home-links"

    if not links_file.exists():
        print(f"Error: Links file '{links_file}' does not exist.")
        sys.exit(1)

    with open(links_file, "r") as f:
        links = [line.strip() for line in f if line.strip()]

    for rel_path in links:
        dest = target_dir / rel_path

        if dest.exists():
            if dest.is_symlink():
                print(f"Removing symlink: {dest}")
                dest.unlink()
            else:
                print(f"Warning: {dest} exists but is not a symlink. Skipping.")

    # Remove the links file
    print(f"Removing links file: {links_file}")
    links_file.unlink()


def main():
    if len(sys.argv) < 3 or ("-u" in sys.argv and len(sys.argv) < 2):
        print("Usage: stow [-u] <target_dir> [<source_dir>]")
        print("Options:")
        print("  -u    Remove symlinks based on .home-links in target_dir")
        sys.exit(1)

    unlink = "-u" in sys.argv
    if unlink:
        sys.argv.remove("-u")

    target_dir = sys.argv[1]

    if unlink:
        remove_links(target_dir)
    else:
        if len(sys.argv) < 3:
            print("Error: <source_dir> is required when not using -u.")
            sys.exit(1)

        source_dir = sys.argv[2]
        symlink_files(source_dir, target_dir)


if __name__ == "__main__":
    main()
