from pyteal import *


def contract_account():
    return Int(1)


if __name__ == "__main__":
    print(compileTeal(contract_account(), Mode.Signature, version=3))
