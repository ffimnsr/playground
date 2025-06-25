struct GetSaleData {
  type: Int;
  is_complete: Bool;
  created_at: Int as uint32;
  marketplace_address: Address;
  nft_address: Address;
  nft_owner_address: Address;
  full_price: Int as coins;
  marketplace_fee_address: Address;
  marketplace_fee: Int as coins;
  royalty_address: Address;
  royalty_amount: Int as coins;
}
struct GetFixPriceData {
  is_complete: Bool;
  created_at: Int as uint32;
  marketplace_address: Address;
  nft_address: Address;
  nft_owner_address: Address;
  full_price: Int as coins;
  marketplace_fee_address: Address;
  marketplace_fee: Int as coins;
  royalty_address: Address;
  royalty_amount: Int as coins;
  sold_at: Int as uint32;
  query_id: Int as uint64;
}
struct Fees {
  marketplace_fee_address: Address;
  marketplace_fee: Int as coins;
  royalty_address: Address;
  royalty_amount: Int as coins;
}
