message(0x5fcc3d14) Transfer {
  query_id: Int as uint64;
  new_owner: Address;
  response_destination: Address?;
  custom_payload: Cell?;
  forward_amount: Int as coins;
  forward_payload: Slice as remaining;
}
message(0x05138d91) OwnershipAssigned {
  query_id: Int as uint64;
  prev_owner: Address;
  forward_payload: Slice as remaining;
}
message(2) Buy {
  query_id: Int as uint64;
}
message(3) CancelSale {
  query_id: Int as uint64;
}
message(555) Fix {
  message: Cell;
  mode: Int as uint8;
}
message(0x6c6c2080) EditSale {
  query_id: Int as uint64;
  new_full_price: Int as coins;
  new_marketplace_fee: Int as coins;
  new_royalty_amount: Int as coins;
}
