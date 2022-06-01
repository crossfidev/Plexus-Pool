from os import path
import os
from typing import List


def mineplex_home() -> str:
    # we rely on a fixed directory structure of the mineplex repo
    # mineplex_HOME/tests_python/tools/paths.py
    cur_path = os.path.dirname(os.path.realpath(__file__))
    mineplex_home = os.path.dirname(os.path.dirname(cur_path)) + '/'
    assert os.path.isfile(f'{mineplex_home}/tests_python/tools/paths.py')
    return mineplex_home


def all_contracts(directories: List[str] = None) -> List[str]:
    if directories is None:
        directories = ['attic', 'opcodes',
                       'macros', 'mini_scenarios', 'non_regression']
    contracts = []
    for directory in directories:
        for contract in os.listdir(path.join(CONTRACT_PATH, directory)):
            contracts.append(path.join(directory, contract))
    return contracts


def all_legacy_contracts() -> List[str]:
    return all_contracts(['legacy'])


# Use environment variable if tests_python are put outside the mineplex
# mineplex_HOME = os.environ.get('mineplex_HOME')
mineplex_HOME = mineplex_home()
mineplex_BINARIES = os.environ.get('mineplex_BINARIES')

CONTRACT_PATH = path.join(mineplex_HOME, 'tests_python', 'contracts')
MACROS_CONTRACT_PATH = path.join(CONTRACT_PATH, 'macros')
ILLTYPED_CONTRACT_PATH = path.join(CONTRACT_PATH, 'ill_typed')
LEGACY_CONTRACT_PATH = path.join(CONTRACT_PATH, 'legacy')
OPCODES_CONTRACT_PATH = path.join(CONTRACT_PATH, 'opcodes')
MINI_SCENARIOS_CONTRACT_PATH = path.join(CONTRACT_PATH,
                                         'mini_scenarios')
ACCOUNT_PATH = path.join(mineplex_HOME, 'tests_python', 'account')
