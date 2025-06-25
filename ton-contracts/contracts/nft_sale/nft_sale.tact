import "@stdlib/deploy";
import "./structs";
import "./messages";

// Reference:
// https://github.com/ton-blockchain/token-contract/blob/main/nft/nft-sale.fc
// https://github.com/getgems-io/nft-contracts/blob/main/packages/contracts/sources/nft-fixprice-sale-v3r3.fc
contract NftSale with Deployable {
  const min_tons_for_storage: Int = ton("0.03");
  const gas_consumption: Int = ton("0.03");
  const min_gas_amount: Int = ton("0.1");

  is_complete: Bool;
  created_at: Int as uint32;
  marketplace_address: Address;
  nft_address: Address;
  nft_owner_address: Address;
  full_price: Int as coins;
  fees: Fees;
  sold_at: Int as uint32;
  query_id: Int as uint64;

  init(marketplace_address: Address, nft_address: Address, nft_owner_address: Address, full_price: Int, fees: Fees) {
    self.marketplace_address = marketplace_address;
    self.nft_address = nft_address;
    self.nft_owner_address = nft_owner_address;
    self.full_price = full_price;
    self.fees = fees;
    self.created_at = now();
    self.is_complete = false;
    self.sold_at = 0;
    self.query_id = 0;
  }

  receive(msg: Buy) {
    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);
    require(msg_value >= self.full_price + self.min_gas_amount, "balance is not enough");

    let nft_owner_fee = self.full_price - self.fees.marketplace_fee - self.fees.royalty_amount + (myBalance() - msg_value);
    send(SendParameters {
      to: self.nft_owner_address,
      value: nft_owner_fee,
      mode: SendPayGasSeparately,
    });

    if (self.fees.royalty_amount > 0) {
      send(SendParameters {
        to: self.fees.royalty_address,
        value: self.fees.royalty_amount,
        mode: SendPayGasSeparately,
      });
    }

    if (self.fees.marketplace_fee > 0) {
      send(SendParameters {
        to: self.fees.marketplace_fee_address,
        value: self.fees.marketplace_fee,
        mode: SendPayGasSeparately,
      });
    }

    send(SendParameters {
      to: self.nft_address,
      value: msg_value,
      bounce: false,
      mode: SendRemainingBalance | SendDestroyIfZero,
      body: Transfer {
        query_id: msg.query_id,
        new_owner: ctx.sender,
        response_destination: ctx.sender,
        custom_payload: emptyCell(),
        forward_amount: ton("0.03"),
        forward_payload: emptySlice()
      }.toCell(),
    });

    self.is_complete = true;
    self.sold_at = now();
    self.query_id = msg.query_id;
  }

  receive(msg: Fix) {
    require(self.is_complete, "not yet completed");
    require(sender() == self.marketplace_address, "invalid sender");
    require((msg.mode & 32) == 0, "invalid mode");

    if (self.sold_at != 0) {
      let ten_min = 10 * 60;
      nativeThrowIf(406, (now() > (self.sold_at - ten_min) && now() < (self.sold_at + ten_min)));
    }

    nativeSendMessage(msg.message, msg.mode);
  }

  receive(msg: EditSale) {
    require(!self.is_complete, "already completed");

    let profit_price: Int = msg.new_full_price - msg.new_marketplace_fee - msg.new_royalty_amount;
    require(profit_price > 1, "profit price is less than 1");

    self.full_price = msg.new_full_price;
    self.fees.marketplace_fee = msg.new_marketplace_fee;
    self.fees.royalty_amount = msg.new_royalty_amount;
  }

  receive(msg: OwnershipAssigned) {
    require(sender() == self.nft_address, "invalid sender");
    self.nft_owner_address = msg.prev_owner;
  }

  receive(msg: CancelSale) {
    self.cancelSale(msg.query_id);
  }

  receive("Cancel") {
    self.cancelSale(0);
  }

  fun cancelSale(query_id: Int) {
    require(!self.is_complete, "already completed");

    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);
    require(msg_value >= self.min_gas_amount, "balance is not enough");
    require(sender() == self.nft_owner_address || sender() == self.marketplace_address, "not authorized");

    send(SendParameters {
      to: self.nft_address,
      value: msg_value,
      bounce: false,
      mode: SendRemainingBalance | SendDestroyIfZero,
      body: Transfer {
        query_id: query_id,
        new_owner: sender(),
        response_destination: sender(),
        custom_payload: emptyCell(),
        forward_amount: 0,
        forward_payload: emptySlice()
      }.toCell(),
    });

    self.is_complete = true;
    self.sold_at = 0;
    self.query_id = 0;
  }

  fun msgValue(value: Int): Int {
    let ton_balance_before_msg: Int = myBalance() - value;
    let storage_fee: Int =
      self.min_tons_for_storage - min(ton_balance_before_msg, self.min_tons_for_storage);
    return value - (storage_fee + self.gas_consumption);
  }

  // --------- Get Function  --------- //
  get fun get_sale_data(): GetSaleData {
    let profit_price = self.full_price - self.fees.marketplace_fee - self.fees.royalty_amount;
    require(profit_price > 1, "profit price is less than 1");

    return GetSaleData {
      type: 0x46495850, // "FIXP"
      is_complete: self.is_complete,
      created_at: self.created_at,
      marketplace_address: self.marketplace_address,
      nft_address: self.nft_address,
      nft_owner_address: self.nft_owner_address,
      full_price: self.full_price,
      marketplace_fee_address: self.fees.marketplace_fee_address,
      marketplace_fee: self.fees.marketplace_fee,
      royalty_address: self.fees.royalty_address,
      royalty_amount: self.fees.royalty_amount,
    }
  }

  get fun get_fix_price_data(): GetFixPriceData {
    let profit_price = self.full_price - self.fees.marketplace_fee - self.fees.royalty_amount;
    require(profit_price > 1, "profit price is less than 1");

    return GetFixPriceData {
      is_complete: self.is_complete,
      created_at: self.created_at,
      marketplace_address: self.marketplace_address,
      nft_address: self.nft_address,
      nft_owner_address: self.nft_owner_address,
      full_price: self.full_price,
      marketplace_fee_address: self.fees.marketplace_fee_address,
      marketplace_fee: self.fees.marketplace_fee,
      royalty_address: self.fees.royalty_address,
      royalty_amount: self.fees.royalty_amount,
      sold_at: self.sold_at,
      query_id: self.query_id
    }
  }
}
