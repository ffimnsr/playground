message(0x693d3950) GetRoyaltyParams {
  query_id: Int as uint64;
}
message(0xa8cb00ad) ReportRoyaltyParams {
  query_id: Int as uint64;
  numerator: Int as uint16;
  denominator: Int as uint16;
  destination: Address;
}
message(1) Mint {
  query_id: Int as uint64;
}
message(2) BatchMint {
  query_id: Int as uint64;
  num: Int;
}
message EditCollectionContent {
  query_id: Int as uint64;
  total_supply: Int as uint32;
  new_content: Cell;
  numerator: Int as uint16;
  denominator: Int as uint16;
  destination: Address;
}
message LogEventMintRecord {
  minter: Address;
  item_id: Int;
  generate_number: Int;
}
message LogEventBatchMintRecord {
  minter: Address;
  num_items: Int;
  generate_number: Int;
}
