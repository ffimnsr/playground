message(1) DeploySale {
  query_id: Int as uint64;
  nft_address: Address;
  nft_owner_address: Address;
  full_price: Int as coins;
  royalty_address: Address;
  royalty_amount: Int as coins;
}
