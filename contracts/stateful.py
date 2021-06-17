from pyteal import *


def stateful():
    return Int(1)


if __name__ == "__main__":
    print(compileTeal(stateful(), Mode.Application, version=3))
