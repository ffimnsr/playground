A blockchain voting model would require all of the same guarantees that any democratic election system has. Particularly when referencing an e-voting system, these include:

- Completeness/Finality of Results
- Robustness and Authenticity of the System (Cryptographic guarantees on fraud, tampering, etc.)
- Eligibility (secure, fast, accurate identity verification system)
- Verifiability
- Unreusable Votes
- Anonymity

Analyzing the potential of a blockchain e-voting system requires viewing the model through the prism of preserving the above components that democratic elections strive to achieve.
#### Completeness/Finality of Results
This refers specifically to the notion that all eligible voters are accepted as able to vote, and all votes are counted correctly. Finality is a concern in modern voting systems where different voting machine software and identification requirements often lead to recounts in tight races. Removing this inefficiency is key to improving the authenticity and acceptance of results.
#### Robustness and Authenticity of the System
Preventing tampering and reducing the ability of fraudulent voters to affect the system.
#### Eligibility
This mainly refers to only legitimate voters being able to vote. Instances of dead people voting and illegal voting remain problems today.
#### Verifiability
Vote auditing, or the ability for anyone to verify that the outcome is the legitimate sum of all eligible votes cast. This concept applies both to the voter that they can be sure their vote was counted and to the general universality of anyone being able to verify the overall outcome is authentic.
#### Unreusable Votes
Voters can vote only once. Applies to elections of representatives, referendums, initiatives, etc.
#### Anonymity
One of the essential components of any democratic voting system, voter anonymity protects them from post-election retribution or coercion at the time of voting. Coercion through “vote buying” is still a concern though and solutions such as blind signatures and multi-faceted private key/password combinations as voting receipts have been floated as solutions.
#### Implementing a Blockchain Voting Model
In a straightforward voting system, we can assume there are at least 3 primary entities participating:

1. Voters
2. Authorities
3. Counters

Importantly, the vital component where a blockchain-based system can have the largest impact is uncoupling the authority entity from the counter entity. The precise reason for doing so only requires a quote from Joseph Stalin to understand why:

> “It’s not the people who vote that count. It’s the people who count the votes.”

Counting of ballots is typically run by the authority (i.e., government) so removing the relationship between the two can provide crucial assurances to voters in regards to confidence in the election’s integrity. Such manipulation may not be prevalent in developed democracies, but it is well-established as a common problem in the developing world, particularly where there is exceptionally inadequate infrastructure.

At the start of a traditional voting process, voters cast their ballots to electronic voting machines or paper ballots at polling places. The counters tally these votes and store them in a centralized database overseen by the authority.

A blockchain voting model removes the connection between counters and authority by uploading votes directly to the blockchain itself, a P2P ledger network with no intermediary.

The digital medium for vote casting is the blockchain rather than a database controlled by an authority. A public blockchain would be the optimal choice for such elections, especially a decentralized ledger such as Bitcoin or Ethereum.

Within such a system, there would only be two primary participating entities, the voter and the authority. The counter would be eliminated, and the authority could simply tally the votes through an accessible and transparent blockchain rather than relying on various polling places and machines to report results to a siloed database. Voters would be able to cast votes directly through their phones or on their computers. However, these mechanisms for voting would require two sets of data:

1. The Actual Votes
2. Identification Documents

Identification documents would need to be validated by the authority — which leaves open potential manipulation still — but could eventually be replaced by whitelisted identities verified through a distributed identity protocol. For now, decentralized identity services are just not developed or ubiquitous enough to function adequately in such a system so the authority (government) would function as the verifier of voter identity. Potential falsification of identities and variations of [Sybil attacks](https://en.wikipedia.org/wiki/Sybil_attack) loom over blockchain voting implementations.

> A **Sybil attack** is a type of attack on a computer [network service](https://en.wikipedia.org/wiki/Network_service "Network service") in which an attacker subverts the service's reputation system by creating a large number of [pseudonymous](https://en.wikipedia.org/wiki/Pseudonymity "Pseudonymity") identities and uses them to gain a disproportionately large influence.

Rather than votes being directly uploaded to the blockchain, they could be encrypted and stored in a distributed file system such as IPFS. Subsequently, the hashes of the votes could be stored on the blockchain that correlates to their IPFS location.

Using IPFS would save storage space, making the voting more scalable on the public ledger while also providing an initial layer of identity obfuscation. A reasonable concern with this process is anonymity though. Voters could potentially be deanonymized through IP mapping or other network-layer tracing methods that connect their vote to their identity.

However, developments in zero-knowledge proofs for anonymous but verifiable voting and network-layer privacy protections such as Dandelion offer some promising potential for preserving privacy on this front.

Additionally, Zcoin — who [recently](https://zcoin.io/worlds-first-large-scale-blockchain-based-political-election-held-on-zcoins-blockchain/) completed a Thailand primary election on their blockchain with over 127,000 votes — implemented [Shamir’s Secret Sharing Scheme](https://zcoin.io/worlds-first-large-scale-blockchain-based-political-election-held-on-zcoins-blockchain/) to ensure that no single entity could decrypt voter information. All of the participating authorities (Thai Election Commission, Democratic Party, candidates) would have to sign off unanimously on decrypting the voting data.

The universal verifiability of votes could also occur in a much more straightforward manner than legacy voting systems. Auditability of elections through the IPFS hash on the blockchain ensures that the outcome is the legitimate sum of all votes cast.

However, individual verifiability is more complicated when attempting to maintain anonymity and is an active area of research for blockchain voting mechanisms. Proposed methods to overcome this issue include having the voter generate a public/private key pair at the time of voting that ensures individual verifiability while not revealing any details about the voter’s identity.

Crucially, robustness and authenticity of votes can be assured through the cryptography of blockchain protocols. With votes tethered to a transaction — such as in Zcoin — votes have the same guarantees as any transaction not to be double spent or manipulated, guaranteed by digital signatures.
#### References

- https://blockonomi.com/implementing-blockchain-voting/

