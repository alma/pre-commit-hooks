"""
Check that passed filenames have got the expected checksum.
"""
import argparse
import hashlib
from typing import Optional
from typing import Sequence

PASS = 0
FAIL = 1


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--algorithm', default='sha1', help='Algorithm')
    parser.add_argument(
        '--check', nargs='+', help='Files to check', required=True,
    )
    parser.add_argument('filenames', nargs='+', help='Files to check')
    args = parser.parse_args(argv)

    files = {}
    for arg in args.check:
        filename, checksum = arg.split(':')
        files[filename] = checksum

    retv = PASS

    algorithm = getattr(hashlib, args.algorithm)

    for filename in args.filenames:
        if filename in files:
            with open(filename, 'rb') as file_obj:
                digest = algorithm(file_obj.read()).hexdigest()

                if digest != files[filename]:
                    retv = FAIL
                    print(
                        f'{bcolors.WARNING}{filename} {args.algorithm} '
                        f'checksum failed.{bcolors.ENDC} '
                        f'Got {bcolors.FAIL}{digest}{bcolors.ENDC} instead of '
                        f'{bcolors.OKGREEN}{checksum}{bcolors.ENDC}',
                    )

    return retv


if __name__ == '__main__':
    exit(main())
