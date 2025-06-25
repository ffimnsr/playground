import "./structs";
import "./messages";

contract NftItem {
  const min_tons_for_storage: Int = ton("0.05");
  const gas_consumption: Int = ton("0.03");

  collection_address: Address;
  item_index: Int as uint32;
  owner: Address;
  editor: Address;
  individual_content: Cell;
  is_initialized: Bool;

  init(
    collection_address: Address,
    item_index: Int,
    owner: Address,
    individual_content: Cell,
    editor: Address
  ) {
    self.collection_address = collection_address;
    self.item_index = item_index;
    self.owner = collection_address;
    self.individual_content = individual_content;
    self.editor = editor;
    self.is_initialized = false;
  }

  receive(msg: Transfer) {
    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);

    // Only owner of the this NFT item can transfer it
    require(ctx.sender == self.owner, "not owner");
    require(msg_value > 0, "invalid amount");

    // Initial Transfer, aka the "Minting" of the NFT
    if (self.is_initialized == false) {
        self.is_initialized = true;
        self.owner = msg.new_owner;
        if (msg.response_destination != null) {
          send(SendParameters {
              to: msg.response_destination!!,
              value: 0,
              mode: SendRemainingValue | SendIgnoreErrors,
              body: Excesses { query_id: msg.query_id }.toCell() //0xd53276db
          });
        }
    } else {
      // Change current owner to the new_owner
      self.owner = msg.new_owner;

      if (msg.forward_amount > 0) {
        send(SendParameters {
          to: msg.new_owner,
          value: msg.forward_amount,
          mode: SendIgnoreErrors,
          bounce: false,
          body: OwnershipAssigned {
            query_id: msg.query_id,
            prev_owner: ctx.sender,
            forward_payload: msg.forward_payload
          }.toCell()
        });
      }

      msg_value -= ctx.readForwardFee();
      if (msg.response_destination != null) {
        send(SendParameters {
          to: msg.response_destination!!,
          value: msg_value - msg.forward_amount,
          mode: SendPayGasSeparately,
          body: Excesses { query_id: msg.query_id }.toCell() // 0xd53276db
        });
      }
    }
  }

  receive(msg: GetStaticData) {
    let ctx: Context = context();
    send(SendParameters {
      to: ctx.sender,
      value: 0,
      mode: SendRemainingValue, // (return msg amount except gas fees)
      bounce: true,
      body: ReportStaticData {
        query_id: msg.query_id,
        index: self.item_index,
        collection: self.collection_address
      }.toCell()
    });
  }

  receive(msg: TransferEditorship) {
    let ctx: Context = context();
    let msg_value: Int = self.msgValue(ctx.value);

    // Only editor of the this NFT item can transfer editorship
    require(ctx.sender == self.editor, "not editor");
    require(msg_value > 0, "invalid amount");
    self.editor = msg.new_editor; // Change current editor to the new_editor
    if (msg.forward_amount > 0) {
      send(SendParameters {
        to: msg.new_editor,
        value: msg.forward_amount,
        mode: SendIgnoreErrors,
        bounce: false,
        body: EditorshipAssigned {
          query_id: msg.query_id,
          prev_editor: self.editor,
          forward_payload: msg.forward_payload
        }.toCell()
      });
    }

    msg_value -= ctx.readForwardFee();
    if (msg.response_destination != null) {
      send(SendParameters {
        to: msg.response_destination!!,
        value: msg_value - msg.forward_amount,
        mode: SendPayGasSeparately,
        body: Excesses { query_id: msg.query_id }.toCell() // 0xd53276db
      });
    }
  }

  receive(msg: EditContent) {
    let ctx: Context = context();
    require(ctx.sender == self.editor, "not editor");
    self.individual_content = msg.new_content;
  }

  fun msgValue(value: Int): Int {
    let ton_balance_before_msg: Int = myBalance() - value;
    let storage_fee: Int =
      self.min_tons_for_storage - min(ton_balance_before_msg, self.min_tons_for_storage);
    return value - (storage_fee + self.gas_consumption);
  }

  // --------- Get Function  --------- //
  get fun get_nft_data(): GetNftData {
    let b: StringBuilder = beginString();
    let individual_data_string: String = self.individual_content.asSlice().asString();
    b.append(individual_data_string);
    b.append(self.item_index.toString());
    b.append(".json");

    return GetNftData {
      init: self.is_initialized,
      index: self.item_index,
      collection_address: self.collection_address,
      owner_address: self.owner,
      individual_content: b.toCell(),
      editor_address: self.editor
    };
  }

  get fun get_editor(): Address {
    return self.editor;
  }

  get fun get_collection_address(): Address {
    return self.collection_address;
  }
}
