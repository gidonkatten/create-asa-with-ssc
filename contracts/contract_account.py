import sys
from pyteal import *


def contract_account(app_id):

    asset_close_to_check = Txn.asset_close_to() == Global.zero_address()
    rekey_check = Txn.rekey_to() == Global.zero_address()
    linked_with_app_call = And(
        Gtxn[0].type_enum() == TxnType.ApplicationCall,
        Gtxn[0].application_id() == Int(app_id)
    )
    fee_check = Txn.fee() <= Int(1000)

    # create asa from escrow
    on_create_asa = Txn.type_enum() == TxnType.AssetConfig

    # fund 1 asa that has been created by escrow
    on_fund_asa = Seq([
        Assert(Txn.type_enum() == TxnType.AssetTransfer),
        Assert(Txn.asset_sender() == Global.zero_address()),
        Assert(asset_close_to_check),
        Assert(Txn.asset_amount() == Int(1)),
        Int(1)
    ])

    return Seq([
        Assert(Txn.group_index() == Int(1)),
        Assert(linked_with_app_call),
        Assert(rekey_check),
        Assert(fee_check),
        Cond(
            [Gtxn[0].application_args[0] == Bytes("create_asa"), on_create_asa],
            [Gtxn[0].application_args[0] == Bytes("fund_asa"), on_fund_asa]
        )
    ])


if __name__ == "__main__":
    arg = int(sys.argv[1])
    print(compileTeal(contract_account(arg), Mode.Signature, version=3))
