import "@stdlib/deploy";
import "@stdlib/ownable";
import "./structs";
import "./messages";
import "./../nft_item/nft_item";

contract NftCollection with Deployable, OwnableTransferable {
  const min_tons_for_storage: Int = ton("0.05");
  const gas_consumption: Int = ton("0.03"); // gas consuption for different operations may differ, so it's better to separate such consts

  next_item_index: Int as uint32 = 0;
  owner: Address;
  royalty_params: RoyaltyParams;
  collection_content: Cell;
  total_supply: Int as uint32;

  init(owner: Address, collection_content: Cell, royalty_params: RoyaltyParams, total_supply: Int) {
    self.owner = owner;
    self.collection_content = collection_content;
    self.royalty_params = royalty_params;
    self.total_supply = total_supply;
  }

  receive(msg: Mint) {
    let ctx: Context = context();
    require(ctx.sender == self.owner, "not owner so can't mint");
    let msg_value: Int = self.msgValue(ctx.value);
    self.mint(msg.query_id, ctx.sender, msg_value);
    emit(
      LogEventMintRecord {
        minter: ctx.sender,
        item_id: self.next_item_index - 1,
        generate_number: msg_value
      }.toCell()
    );
  }

  receive(msg: BatchMint) {
    let ctx: Context = context();
    require(ctx.sender == self.owner, "not owner so can't mint");
    require(msg.num < 250, "limit of 250 actions");

    let msg_value: Int = self.msgValue(ctx.value);
    let i: Int = 0;
    do {
      self.mint(msg.query_id, ctx.sender, msg_value);
      i += 1;
    } until (i >= msg.num);

    emit(
      LogEventBatchMintRecord {
        minter: ctx.sender,
        num_items: msg.num,
        generate_number: msg_value
      }.toCell()
    );
  }

  // ===== Private Methods ===== //
  fun mint(query_id: Int, sender: Address, msg_value: Int) {
    require(self.next_item_index >= 0, "invalid item index");
    require(self.next_item_index < self.total_supply, "exceed total supply");
    let nft_init: StateInit = self.nftItemInit(self.next_item_index);

    send(SendParameters {
      to: contractAddress(nft_init),
      value: msg_value,
      bounce: false,
      mode: SendIgnoreErrors,
      body: Transfer {
        query_id: query_id,
        new_owner: sender,
        response_destination: self.owner,
        custom_payload: emptyCell(),
        forward_amount: 0,
        forward_payload: emptySlice()
      }.toCell(),
      code: nft_init.code,
      data: nft_init.data
    });
    self.next_item_index += 1;
  }

  fun nftItemInit(item_index: Int): StateInit {
    return
      initOf NftItem(myAddress(),
        item_index,
        self.owner,
        self.collection_content,
        self.owner
      );
  }

  receive(msg: GetRoyaltyParams) {
    let ctx: Context = context(); // get sender info
    send(SendParameters{
      to: ctx.sender,
      value: 0,
      mode: SendRemainingValue,
      bounce: false,
      body: ReportRoyaltyParams {
        query_id: msg.query_id,
        numerator: self.royalty_params.numerator,
        denominator: self.royalty_params.denominator,
        destination: self.owner
      }.toCell()
    });
  }

  receive(msg: EditCollectionContent) {
    // Only Owner of the this NFT Collection can update it.
    self.requireOwner();
    self.total_supply = msg.total_supply;
    self.collection_content = msg.new_content;
    self.royalty_params = RoyaltyParams {
      numerator: msg.numerator,
      denominator: msg.denominator,
      destination: msg.destination
    };
  }

  fun msgValue(value: Int): Int {
    let ton_balance_before_msg: Int = myBalance() - value;
    let storage_fee: Int =
      self.min_tons_for_storage - min(ton_balance_before_msg, self.min_tons_for_storage);
    return value - (storage_fee + self.gas_consumption);
  }

  // ------------------ Get Function  ------------------ //
  get fun get_collection_data(): CollectionData {
    let b: StringBuilder = beginString();
    let collection_data_string: String = self.collection_content.asSlice().asString();
    b.append(collection_data_string);
    b.append("meta.json");
    return
      CollectionData {
        next_item_index: self.next_item_index,
        collection_content: b.toCell(),
        owner_address: self.owner
      };
  }

  get fun get_nft_address_by_index(item_index: Int): Address? {
    let init_code: StateInit = self.nftItemInit(item_index);
    return contractAddress(init_code);
  }

  get fun get_nft_content(index: Int, individual_content: Cell): Cell {
    let b: StringBuilder = beginString();
    let ic: String = individual_content.asSlice().asString();
    b.append(ic);
    b.append(index.toString());
    b.append(".json");
    return b.toCell();
  }

  get fun royalty_params(): RoyaltyParams {
    return self.royalty_params;
  }

  get fun developer(): Cell {
    let b: StringBuilder = beginString();
    b.append("po.ppon.im");
    return b.toCell();
  }
}
