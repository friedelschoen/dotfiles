#!/usr/bin/env python3

## PREPROCESSOR

import sys
import io
import os
import re
import subprocess
import shutil

def preprocessor(src, dest):
    defs = {}
    incond = False
    cond = True

    for line in src:
        cmd = line.strip()
        if cmd.startswith('@define'):
            _, name, value = cmd.split(' ', 3)
            defs[name] = preline(value, defs)
        elif cmd.startswith('@include'):
            _, path = cmd.split(' ', 2)
            with open(path) as f:
                preprocessor(f, dest)
        elif cmd.startswith('@ifeq'):
            _, name, value = cmd.split(' ', 3)
            incond = True
            cond = name in defs and defs[name] == value
        elif cmd.startswith('@ifneq'):
            _, name, value = cmd.split(' ', 3)
            incond = True
            cond = name not in defs or defs[name] != value
        elif cmd.startswith('@else'):
            if not incond:
                raise ValueError("not in condition")
            cond = not cond
        elif cmd.startswith('@endif'):
            if not incond:
                raise ValueError("not in condition")
            incond = False
        elif cmd.startswith("@@"):
            pass
        else:
            dest.write(preline(line, defs))

def preline(line: str, defs: dict) -> str:
    def replacer(match):
        content = match[1]
        if ':' in content:
            kind, value = content.split(':', 1)
            if kind == 'env':
                return os.environ.get(value, '')
            elif kind == 'shell':
                try:
                    return subprocess.check_output(value, shell=True, text=True).strip()
                except subprocess.CalledProcessError:
                    return ''
            else:
                return ''
        elif content in defs:
            return defs[content]
        else:
            return match[0]

    return re.sub(r'@([^@]+)@', replacer, line)

if __name__ == "__main__":
    dest = sys.argv[1]
    src = sys.argv[2]

    try:
        os.mkdir(dest)
    except FileExistsError:
        pass

    for srcroot, dirs, files in os.walk(src, topdown=True):
        srcroot += '/'
        destroot = dest + '/' + srcroot[len(src):]

        try:
            os.mkdir(destroot)
        except FileExistsError:
            pass

        for fpath in files:
            if fpath.endswith(".in"):
                with open(srcroot + fpath) as srcf, open(destroot + fpath[:-3], 'w') as destf:
                    preprocessor(srcf, destf)
            else:
                try:
                    os.unlink(destroot + fpath)
                except FileNotFoundError:
                    pass
                os.symlink('../' * srcroot.count('/') + srcroot + fpath, destroot + fpath)
