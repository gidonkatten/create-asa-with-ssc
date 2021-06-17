from pyteal import *


def stateful():
    return Int(1)


if __name__ == "__main__":
    program = stateful()
    print(compileTeal(program, Mode.Application))
