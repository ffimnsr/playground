struct Royalty {
    marketplaceFeeAddress: Address;
    marketplaceNumerator: Int as uint32; // TEP-66 says numerator and denominator are contained in uint16, but reference contract uses uint32
    marketplaceDenominator: Int as uint32;
    royaltyAddress: Address;
    royaltyNumerator: Int as uint32;
    royaltyDenominator: Int as uint32;
}

struct OfferParameters {
    type: Int = 0x4f46464552;
    isComplete: Bool;
    createdAt: Int as uint32;
    finishAt: Int as uint32;
    marketplaceAddress: Address; // aka admin address
    nftAddress: Address;
    offerOwnerAddress: Address;
    fullPrice: Int as coins;
    marketplaceFeeAddress: Address;
    marketplaceNumerator: Int as uint32;
    marketplaceDenominator: Int as uint32;
    royaltyAddress: Address;
    royaltyNumerator: Int as uint32;
    royaltyDenominator: Int as uint32;
    profitPrice: Int as coins;
}
