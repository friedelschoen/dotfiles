#!/usr/bin/env python3

import os
import sys
import shutil
from pathlib import Path

YES_ANSWER = ["y", "yes"]
NO_ANSWER = ["n", "no"]

def rm_exist(dest, rel_path):
    print(f"Error: {rel_path} exists and is not a symlink created by this script.")
    answer = ""
    while answer.lower() not in YES_ANSWER + NO_ANSWER:
        answer = input("remove [y/n]:")

    if answer.lower() in NO_ANSWER:
        sys.exit(0)

    os.remove(str(dest))

def symlink_files(source_dir, target_dir):
    target_dir = Path(target_dir).resolve()
    links_file = target_dir / ".home-links"

    # Load existing links from the links file if it exists
    existing_links = set()
    if links_file.exists():
        with open(links_file, "r") as f:
            existing_links = set(line.strip() for line in f if line.strip())

    new_links = set()

    if source_dir is not None:
        source_dir = Path(source_dir).resolve()
        if not source_dir.is_dir():
            print(f"Error: Source directory '{source_dir}' does not exist or is not a directory.")
            sys.exit(1)
        for root, _, files in os.walk(source_dir):
            for file in files:
                src = Path(root) / file
                rel_path = src.relative_to(source_dir)
                dest = target_dir / rel_path

                # Ensure parent directory exists for the destination
                dest.parent.mkdir(parents=True, exist_ok=True)

                if dest.exists():
                    if dest.is_symlink() and str(rel_path) in existing_links:
                        print(f"SKIP {rel_path}")
                        new_links.add(str(rel_path))
                        continue
                    else:
                        rm_exist(dest, rel_path)

                print(f"LINK {rel_path!s}")
                dest.symlink_to(os.path.relpath(src, dest.parent))
                new_links.add(str(rel_path))

        # Append new links to the .home-links file
        with open(links_file, "w") as f:
            for link in new_links:
                f.write(link + "\n")

    for rel_path in existing_links - new_links:
        print(f"RM   {rel_path!s}")
        os.unlink(target_dir / rel_path)

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
        symlink_files(None, target_dir)
    else:
        if len(sys.argv) < 3:
            print("Error: <source_dir> is required when not using -u.")
            sys.exit(1)

        source_dir = sys.argv[2]
        shutil.rmtree(target_dir + "/.installed-dotfiles")
        shutil.copytree(source_dir, target_dir + "/.installed-dotfiles")
        symlink_files(target_dir + "/.installed-dotfiles", target_dir)

if __name__ == "__main__":
    main()
