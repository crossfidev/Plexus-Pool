#!/usr/bin/env python3
import subprocess
import shutil
import glob
import pathlib
import os
import re
import argparse
from typing import List, Any


def print_log(log, color=True):
    color_code = '\033[34m'
    endc = '\033[0m'
    print(f'{color_code}# {log}{endc}' if color else f'# {log}')


def print_command(cmd, color=True):
    color_code = '\033[34m'
    endc = '\033[0m'
    cmd_str = " ".join(cmd)
    print(f'{color_code}# {cmd_str}{endc}' if color else f'# {cmd_str}')


# simple parser for `opam env`
TERM_REGEX = r'''(?mx)
    \s*(?:
        (?P<brackl>\()|
        (?P<brackr>\))|
        (?P<num>\-?\d+\.\d+|\-?\d+)|
        (?P<sq>"[^"]*")|
        (?P<s>[^(^)\s]+)
       )'''


def parse_sexp(sexp):
    stack = []
    out: List[Any] = []
    for termtypes in re.finditer(TERM_REGEX, sexp):
        term, value = [(t, v)
                       for t, v in termtypes.groupdict().items() if v][0]
        if term == 'brackl':
            stack.append(out)
            out = []
        elif term == 'brackr':
            assert stack, "Trouble with nesting of brackets"
            tmpout, out = out, stack.pop(-1)
            out.append(tmpout)
        elif term == 'num':
            val = float(value)
            if val.is_integer():
                val = int(val)
            out.append(val)
        elif term == 'sq':
            out.append(value[1:-1])
        elif term == 's':
            out.append(value)
        else:
            raise NotImplementedError(f'Error: {term, value}')
    assert not stack, "Trouble with nesting of brackets"
    return out[0]


def opam_env(mineplex_build):
    process = subprocess.Popen(['opam', 'env', '--sexp', '--set-switch'],
                               stdout=subprocess.PIPE,
                               cwd=mineplex_build)
    out, _err = process.communicate()
    out_str = out.decode('utf-8')
    env = {x[0]: x[1] for x in parse_sexp(out_str)}
    return env


def run(cmd, cwd, env=None):
    print_command(cmd)
    if env is None:
        subprocess.run(cmd, check=True, cwd=cwd)
    else:
        subprocess.run(cmd, check=True, cwd=cwd, env=env)


def build(branch, mineplex_home, mineplex_build, mineplex_binaries):

    if os.listdir(mineplex_build):
        error_msg = f'{mineplex_build} is not empty. Should be a git directory'
        assert os.path.isdir(f"{mineplex_build}/.git"), error_msg
    else:
        print_log(f'{mineplex_build} is empty. Cloning {mineplex_home}')
        run(['git', 'clone', mineplex_home], mineplex_build)

    run(['git', 'clean', '-f'], mineplex_build)
    run(['git', 'reset', '--hard'], mineplex_build)
    run(['git', 'checkout', branch], mineplex_build)
    run(['make', 'build-deps'], mineplex_build)

    new_env = opam_env(mineplex_build)
    print_log(f'Extending current env with opam env: {new_env}')
    env = {**os.environ, **new_env}

    run(['make'], mineplex_build, env=env)

    branch_dir = os.path.join(mineplex_binaries, branch)
    print_log(f'Copying binaries to {branch_dir}')
    pathlib.Path(branch_dir).mkdir(parents=True, exist_ok=True)

    for filename in glob.glob(f'{mineplex_build}/mineplex-*'):
        dest = os.path.join(branch_dir, os.path.basename(filename))
        if os.path.exists(dest):
            print_log(f"{dest} already exists, don't copy")
        print_log(f'copy {filename} to {branch_dir}')
        shutil.copy(filename, branch_dir)


def prepare_binaries(
        mineplex_home,
        mineplex_build,
        mineplex_binaries,
        branch_list):
    assert branch_list, "branch list is empty"
    assert os.path.isdir(mineplex_binaries), f"{mineplex_binaries} doesn't exist"
    assert os.path.isdir(mineplex_build), f"{mineplex_build} doesn't exist"
    assert os.path.isdir(mineplex_home), f"{mineplex_home} doesn't exist"
    for branch in branch_list:
        branch_dir = os.path.join(mineplex_binaries, branch)
        if os.path.isdir(branch_dir) and os.listdir(branch_dir):
            print_log(f"Binaries for branch {branch} found. Skip.")
        else:
            print_log(f"Binaries for branch {branch} not found. Build.")
            build(branch, mineplex_home, mineplex_build, mineplex_binaries)


def main():
    parser = argparse.ArgumentParser(description='build_branch.py')

    parser.add_argument('--clone', dest='clone_dir', metavar='DIR',
                        help='repository to be cloned', required=True)
    parser.add_argument('--build-dir', dest='build_dir', metavar='DIR',
                        help='repository where executables will be built',
                        required=True
                        )
    parser.add_argument('--bin-dir', dest='bin_dir', metavar='DIR',
                        help='repository where executables will be copied',
                        required=True)
    parser.add_argument('branches', metavar='BRANCH', type=str, nargs='*',
                        help='list of branches')
    args = parser.parse_args()
    prepare_binaries(args.clone_dir, args.build_dir, args.bin_dir,
                     args.branches)


if __name__ == "__main__":
    main()
