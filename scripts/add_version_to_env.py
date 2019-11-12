#!/usr/bin/env python3

import argparse
import os
import shutil


def add_version(image, path):
    if not os.path.isfile('.env'):
        if os.path.isfile('.env.example'):
            shutil.copyfile('.env.example', '.env')
        else:
            print("No existing .env file, creating a new one")
            with open('.env', 'w') as f:
                f.write('')

    with open('.env', 'r') as f:
        lines = f.read().split('\n')

    out = []

    found = False

    for line in lines:
        if (not found) and line.startswith(image + '='):
            line = image + '=' + path
            found = True

        if line.strip():
            out.append(line)

    if not found:
        line = image + '=' + path
        out.append(line)

    shutil.copyfile('.env', '.env.old')
    with open('.env', 'w') as f:
        f.write('\n'.join(out))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Write released docker image name to .env file'
    )
    parser.add_argument("--file", required=True,
                        type=str, help="Path to txt file")
    parser.add_argument("--name", required=True, type=str,
                        help="Environment variable name")
    args = parser.parse_args()

    add_version(args.name, args.file)
