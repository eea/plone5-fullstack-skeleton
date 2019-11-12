#!/usr/bin/env python3

import argparse
import os
import shutil


def add_version(var_name, version_file_path):
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
    with open(version_file_path) as v:
        docker_image_name = v.read().strip()

    for line in lines:
        if (not found) and line.startswith(var_name + '='):
            line = var_name + '=' + docker_image_name
            found = True

        if line.strip():
            out.append(line)

    if not found:
        line = var_name + '=' + docker_image_name
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
