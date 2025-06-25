import "@stdlib/deploy";
import "./structs";
import "./messages";
import "./../nft_sale/nft_sale";

// Reference:
// https://github.com/getgems-io/nft-contracts/blob/main/packages/contracts/sources/nft-marketplace-v2.fc
contract NftMarketplace with Deployable {
  const min_tons_for_storage: Int = ton("0.03");
  const gas_consumption: Int = ton("0.03");
  const min_gas_amount: Int = ton("0.1");

  seq_no: Int as uint32;
  subwallet: Int as uint32;
  public_key: Int as uint256;

  init(seq_no: Int, subwallet: Int, public_key: Int) {
    self.seq_no = seq_no;
    self.subwallet = subwallet;
    self.public_key = public_key;
  }

  receive(msg: DeploySale) {
    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);

    let msg_hash = msg.body.toCell().hash();
    require(checkSignature(msg_hash, msg.signature, self.public_key), "signature is invalid");

    let sale_init: StateInit = self.saleInit(
      msg.body.nft_address,
      msg.body.nft_owner_address,
      msg.body.full_price,
      msg.body.marketplace_fee_address,
      msg.body.marketplace_fee,
      msg.body.royalty_address,
      msg.body.royalty_amount
    );

    send(SendParameters {
      to: contractAddress(sale_init),
      value: msg_value,
      bounce: false,
      mode: SendRemainingBalance,
      body: Transfer {
        query_id: msg.body.query_id,
        new_owner: ctx.sender,
        response_destination: ctx.sender,
        custom_payload: emptyCell(),
        forward_amount: 0,
        forward_payload: emptySlice()
      }.toCell(),
      code: sale_init.code,
      data: sale_init.data
    });
  }

  fun saleInit(
    nft_address: Address,
    nft_owner_address: Address,
    full_price: Int,
    marketplace_fee_address: Address,
    marketplace_fee: Int,
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
          marketplace_fee_address: marketplace_fee_address,
          marketplace_fee: marketplace_fee,
          royalty_address: royalty_address,
          royalty_amount: royalty_amount
        }
      );
  }

  fun msgValue(value: Int): Int {
    let ton_balance_before_msg: Int = myBalance() - value;
    let storage_fee: Int =
      self.min_tons_for_storage - min(ton_balance_before_msg, self.min_tons_for_storage);
    return value - (storage_fee + self.gas_consumption);
  }

  // --------- Get Function  --------- //
  get fun seqno(): Int {
    return self.seq_no;
  }

  get fun get_public_key(): Int {
    return self.public_key;
  }

  get fun get_marketplace_data(): GetMarketplaceData {
    return GetMarketplaceData {
      seqno: self.seq_no,
      public_key: self.public_key
    };
  }
}
