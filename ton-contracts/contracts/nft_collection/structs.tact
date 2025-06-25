struct CollectionData {
  next_item_index: Int as uint32;
  collection_content: Cell;
  owner_address: Address;
}
struct RoyaltyParams {
  numerator: Int as uint16;
  denominator: Int as uint16;
  destination: Address;
}
