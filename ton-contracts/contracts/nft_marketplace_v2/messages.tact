struct DeploySaleBody {
  query_id: Int as uint64;
  nft_address: Address;
  nft_owner_address: Address;
  full_price: Int as coins;
  marketplace_fee_address: Address;
  marketplace_fee: Int as coins;
  royalty_address: Address;
  royalty_amount: Int as coins;
}
message(1) DeploySale {
  signature: Slice as bytes64;
  body: DeploySaleBody;
}
