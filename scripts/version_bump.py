#!/usr/bin/env python3

import sys
from decimal import Decimal


def release(destination):
    with open(destination, 'r') as f:
        content = f.read().strip()

    dockerimage, version = content.split(':')
    bits = version.split('-')

    # only support a simple version, such as

    if len(bits) != 2:
        print("Version file is not in proper format. \n"
              "Use version such as 5.2-1.0")
        sys.exit(137)

    left, right = bits
    right = Decimal(right)
    right += Decimal('0.01')

    new_version = "{}:{}-{}".format(dockerimage, left, right)
    print("Bumping version: {} => {}".format(version, new_version))

    with open(destination, 'w') as f:
        f.write(new_version)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('destination', help="Path to version file")
    args = parser.parse_args()
    release(args.destination)
