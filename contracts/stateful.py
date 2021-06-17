from pyteal import *


def stateful():

    on_set_escrow = Seq([
        Assert(Txn.sender() == Global.creator_address()),
        App.globalPut(Bytes('escrow'), Txn.application_args[1]),
        Int(1)
    ])

    program = Cond(
        [Txn.on_completion() == OnComplete.DeleteApplication, Int(0)],
        [Txn.on_completion() == OnComplete.UpdateApplication, Int(0)],
        [Txn.on_completion() == OnComplete.CloseOut, Int(0)],
        [Txn.on_completion() == OnComplete.OptIn, Int(0)],
        # On app creation
        [Txn.application_id() == Int(0), Int(1)],
        # Must be a NoOp transaction
        [Txn.application_args[0] == Bytes("set_escrow"), on_set_escrow],

    )

    return program


if __name__ == "__main__":
    print(compileTeal(stateful(), Mode.Application, version=3))
