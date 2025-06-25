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
message(0xd53276db) Excesses {
  query_id: Int as uint64;
}
message(0x2fcb26a2) GetStaticData {
  query_id: Int as uint64;
}
message(0x8b771735) ReportStaticData {
  query_id: Int as uint64;
  index: Int;
  collection: Address;
}
message(0x1c04412a) TransferEditorship {
  query_id: Int as uint64;
  new_editor: Address;
  response_destination: Address?;
  forward_amount: Int as coins;
  forward_payload: Slice as remaining;
}
message(0x511a4463) EditorshipAssigned {
  query_id: Int as uint64;
  prev_editor: Address;
  forward_payload: Slice as remaining;
}
message(0x1a0b9d51) EditContent {
  query_id: Int as uint64;
  new_content: Cell;
}
