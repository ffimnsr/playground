import "@stdlib/deploy";
import "@stdlib/ownable";
import "./structs";
import "./messages";
import "./../nft_sale/nft_sale";

// Reference:
// https://github.com/getgems-io/nft-contracts/blob/main/packages/contracts/sources/nft-marketplace-v2.fc
contract NftMarketplace with Deployable, OwnableTransferable {
  const min_tons_for_storage: Int = ton("0.03");
  const gas_consumption: Int = ton("0.03");

  owner: Address;
  marketplace_fee: Int as coins;

  init(owner_address: Address, marketplace_fee: Int) {
    self.owner = owner_address;
    self.marketplace_fee = marketplace_fee;
  }

  receive(msg: DeploySale) {
    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);

    require(ctx.sender == self.owner, "only owner can deploy sale");

    let sale_init: StateInit = self.saleInit(
      msg.nft_address,
      msg.nft_owner_address,
      msg.full_price,
      msg.royalty_address,
      msg.royalty_amount
    );

    send(SendParameters {
      to: contractAddress(sale_init),
      value: msg_value,
      bounce: false,
      mode: SendRemainingBalance,
      body: Transfer {
        query_id: msg.query_id,
        new_owner: self.owner,
        response_destination: self.owner,
        custom_payload: emptyCell(),
        forward_amount: 0,
        forward_payload: emptySlice()
      }.toCell(),
      code: sale_init.code,
      data: sale_init.data
    });
  }

  fun msgValue(value: Int): Int {
    let ton_balance_before_msg: Int = myBalance() - value;
    let storage_fee: Int =
      self.min_tons_for_storage - min(ton_balance_before_msg, self.min_tons_for_storage);
    return value - (storage_fee + self.gas_consumption);
  }

  fun saleInit(
    nft_address: Address,
    nft_owner_address: Address,
    full_price: Int,
    royalty_address: Address,
    royalty_amount: Int
  ): StateInit {
    return
      initOf NftSale(
        myAddress(),
        nft_address,
        nft_owner_address,
        full_price,
        Fees {
          marketplace_fee_address: self.owner,
          marketplace_fee: self.marketplace_fee,
          royalty_address: royalty_address,
          royalty_amount: royalty_amount
        }
      );
  }

    // --------- Get Function  --------- //
  get fun get_marketplace_data(): GetMarketplaceData {
    return GetMarketplaceData {
      marketplace_fee: self.marketplace_fee
    }
  }
}
