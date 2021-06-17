import sys
from pyteal import *


def contract_account(app_id):
    return Int(app_id)


if __name__ == "__main__":
    arg = int(sys.argv[1])
    print(compileTeal(contract_account(arg), Mode.Signature, version=3))
