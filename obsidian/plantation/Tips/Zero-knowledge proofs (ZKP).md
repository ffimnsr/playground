A zero-knowledge proof is a way of proving the validity of a statement without revealing the statement itself. The ‘prover’ is the party trying to prove a claim, while the ‘verifier’ is responsible for validating the claim.

Zero-knowledge proofs first appeared in a 1985 paper, “[The knowledge complexity of interactive proof systems(opens in a new tab)](http://people.csail.mit.edu/silvio/Selected%20Scientific%20Papers/Proof%20Systems/The_Knowledge_Complexity_Of_Interactive_Proof_Systems.pdf)” which provides a definition of zero-knowledge proofs widely used today:

> A zero-knowledge protocol is a method by which one party (the prover) **can prove** to another party (the verifier) **that something is true, without revealing any information** apart from the fact that this specific statement is true.

A zero-knowledge proof allows you to prove the truth of a statement without sharing the statement’s contents or revealing how you discovered the truth. To make this possible, zero-knowledge protocols rely on algorithms that take some data as input and return ‘true’ or ‘false’ as output.

A zero-knowledge protocol must satisfy the following criteria:

1. **Completeness**: If the input is valid, the zero-knowledge protocol always returns ‘true’. Hence, if the underlying statement is true, and the prover and verifier act honestly, the proof can be accepted.
2. **Soundness**: If the input is invalid, it is theoretically impossible to fool the zero-knowledge protocol to return ‘true’. Hence, a lying prover cannot trick an honest verifier into believing an invalid statement is valid (except with a tiny margin of probability).
3. **Zero-knowledge**: The verifier learns nothing about a statement beyond its validity or falsity (they have “zero knowledge” of the statement). This requirement also prevents the verifier from deriving the original input (the statement’s contents) from the proof.

In basic form, a zero-knowledge proof is made up of three elements: **witness**, **challenge**, and **response**.

- **Witness**: With a zero-knowledge proof, the prover wants to prove knowledge of some hidden information. The secret information is the “witness” to the proof, and the prover's assumed knowledge of the witness establishes a set of questions that can only be answered by a party with knowledge of the information. Thus, the prover starts the proving process by randomly choosing a question, calculating the answer, and sending it to the verifier.
- **Challenge**: The verifier randomly picks another question from the set and asks the prover to answer it.
- **Response**: The prover accepts the question, calculates the answer, and returns it to the verifier. The prover’s response allows the verifier to check if the former really has access to the witness. To ensure the prover isn’t guessing blindly and getting the correct answers by chance, the verifier picks more questions to ask. By repeating this interaction many times, the possibility of the prover faking knowledge of the witness drops significantly until the verifier is satisfied.

The above describes the structure of an ‘interactive zero-knowledge proof’. Early zero-knowledge protocols used interactive proving, where verifying the validity of a statement required back-and-forth communication between provers and verifiers.

A good example that illustrates how interactive proofs work is Jean-Jacques Quisquater’s famous [Ali Baba cave story(opens in a new tab)](https://en.wikipedia.org/wiki/Zero-knowledge_proof#The_Ali_Baba_cave). In the story, Peggy (the prover) wants to prove to Victor (the verifier) that she knows the secret phrase to open a magic door without revealing the phrase.
#### Why do we need zero-knowledge proofs?
Zero-knowledge proofs represented a breakthrough in applied cryptography, as they promised to improve security of information for individuals. Consider how you might prove a claim (e.g., “I am a citizen of X country”) to another party (e.g., a service provider). You’d need to provide “evidence” to back up your claim, such as a national passport or driver’s license.

But there are problems with this approach, chiefly the lack of privacy. Personally Identifiable Information (PII) shared with third-party services is stored in central databases, which are vulnerable to hacks. With identity theft becoming a critical issue, there are calls for more privacy-protecting means of sharing sensitive information.

Zero-knowledge proofs solve this problem by **eliminating the need to reveal information to prove validity of claims**. The zero-knowledge protocol uses the statement (called a ‘witness’) as input to generate a succinct proof of its validity. This proof provides strong guarantees that a statement is true without exposing the information used in creating it.

Use-cases for zero-knowledge proofs:

- Anonymous payments
- Identity protection
- Authentication
- Verifiable computation
- Reducing bribery and collision in on-chain voting
#### Non-interactive zero-knowledge proofs
While revolutionary, interactive proving had limited usefulness since it required the two parties to be available and interact repeatedly. Even if a verifier was convinced of a prover’s honesty, the proof would be unavailable for independent verification (computing a new proof required a new set of messages between the prover and verifier).

To solve this problem, Manuel Blum, Paul Feldman, and Silvio Micali suggested the first [non-interactive zero-knowledge proofs(opens in a new tab)](https://dl.acm.org/doi/10.1145/62212.62222) where the prover and verifier have a shared key. This allows the prover to demonstrate their knowledge of some information (i.e., witness) without providing the information itself.

Unlike interactive proofs, noninteractive proofs required only one round of communication between participants (prover and verifier). The prover passes the secret information to a special algorithm to compute a zero-knowledge proof. This proof is sent to the verifier, who checks that the prover knows the secret information using another algorithm.

Non-interactive proving reduces communication between prover and verifier, making ZK-proofs more efficient. Moreover, once a proof is generated, it is available for anyone else (with access to the shared key and verification algorithm) to verify.
#### Types of zero-knowledge proofs
##### ZK-SNARKs
ZK-SNARK is an acronym for **Zero-Knowledge Succinct Non-Interactive Argument of Knowledge**. The ZK-SNARK protocol has the following qualities:

- **Zero-knowledge**: A verifier can validate the integrity of a statement without knowing anything else about the statement. The only knowledge the verifier has of the statement is whether it is true or false.
- **Succinct**: The zero-knowledge proof is smaller than the witness and can be verified quickly.
- **Non-interactive**: The proof is ‘non-interactive’ because the prover and verifier only interact once, unlike interactive proofs that require multiple rounds of communication.
- **Argument**: The proof satisfies the ‘soundness’ requirement, so cheating is extremely unlikely.
- **(Of) Knowledge**: The zero-knowledge proof cannot be constructed without access to the secret information (witness). It is difficult, if not impossible, for a prover who doesn’t have the witness to compute a valid zero-knowledge proof.

The ‘shared key’ mentioned earlier refers to public parameters that the prover and verifier agree to use in generating and verifying proofs. Generating the public parameters (collectively known as the Common Reference String (CRS)) is a sensitive operation because of its importance in the protocol’s security. If the entropy (randomness) used in generating the CRS gets into the hands of a dishonest prover, they can compute false proofs.

[Multi-party computation (MPC)(opens in a new tab)](https://en.wikipedia.org/wiki/Secure_multi-party_computation) is a way of reducing the risks in generating public parameters. Multiple parties participate in a [trusted setup ceremony(opens in a new tab)](https://zkproof.org/2021/06/30/setup-ceremonies/amp/), where each person contributes some random values to generate the CRS. As long as one honest party destroys their portion of the entropy, the ZK-SNARK protocol retains computational soundness.

Trusted setups require users to trust the participants in parameter-generation. However, the development of ZK-STARKs has enabled proving protocols that work with a non-trusted setup.
##### ZK-STARKs
ZK-STARK is an acronym for **Zero-Knowledge Scalable Transparent Argument of Knowledge**. ZK-STARKs are similar to ZK-SNARKs, except that they are:

- **Scalable**: ZK-STARK is faster than ZK-SNARK at generating and verifying proofs when the size of the witness is larger. With STARK proofs, prover and verification times only slightly increase as the witness grows (SNARK prover and verifier times increase linearly with witness size).
- **Transparent**: ZK-STARK relies on publicly verifiable randomness to generate public parameters for proving and verification instead of a trusted setup. Thus, they are more transparent compared to ZK-SNARKs.

ZK-STARKs produce larger proofs than ZK-SNARKs meaning they generally have higher verification overheads. However, there are cases (such as proving large datasets) where ZK-STARKs may be more cost-effective than ZK-SNARKs.
#### Drawbacks of using zero-knowledge proofs
##### Hardware costs
Generating zero-knowledge proofs involves very complex calculations best performed on specialized machines. As these machines are expensive, they are often out of the reach of regular individuals. Additionally, applications that want to use zero-knowledge technology must factor in hardware costs—which may increase costs for end-users.

