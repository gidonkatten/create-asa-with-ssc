from pyteal import *


def stateful():

    # set escrow address
    on_set_escrow = Seq([
        Assert(Txn.sender() == Global.creator_address()),
        App.globalPut(Bytes('escrow'), Txn.application_args[1]),
        Int(1)
    ])

    increment_counter = App.globalPut(
        Bytes('counter'),
        App.globalGet(Bytes('counter')) + Int(1)
    )

    linked_with_escrow = Gtxn[1].sender() == App.globalGet(Bytes('escrow'))

    digit_stored = ScratchVar(TealType.uint64)

    asa_creation = And(
        Gtxn[1].type_enum() == TxnType.AssetConfig,
        Eq(
            Gtxn[1].config_asset_name(),
            Concat(
                Bytes('AppASA-'),
                Substring(
                    Bytes('0123456789'),
                    digit_stored.load(),
                    digit_stored.load() + Int(1)
                )
            )
        )
    )

    # create asa from escrow
    on_create_asa = Seq([
        Assert(Global.group_size() == Int(2)),
        Assert(linked_with_escrow),
        digit_stored.store(App.globalGet(Bytes('counter')) % Int(10)),
        Assert(asa_creation),
        increment_counter,
        Int(1)
    ])

    # fund 1 asa that has been created by escrow
    on_fund_asa = Seq([
        Assert(Global.group_size() == Int(2)),
        Assert(linked_with_escrow),
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
        [Txn.application_args[0] == Bytes("create_asa"), on_create_asa],
        [Txn.application_args[0] == Bytes("fund_asa"), on_fund_asa]
    )

    return And(Txn.group_index() == Int(0), program)


if __name__ == "__main__":
    print(compileTeal(stateful(), Mode.Application, version=3))
