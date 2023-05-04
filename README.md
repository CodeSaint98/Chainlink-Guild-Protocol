# Guild Protocol

## Introduction
### The guild protocol is a blockchain based freelancing platform that utilizes decentralization and automated smart contracts to cut out unwanted fees while still maintaining a relationship between client and freelancer. It is a single-token system that uses Guild Tokens(GT) to incentivize freelancers to provide quality work. Third parties are also incentivized to vet the work done with these same tokens. Third parties are decided on based on a Proof of Stake consensus algorithm.

## Client-side features
### * The client can create a proposal with an appropriate bounty amount.
### * The client has the option to vet the bidding freelancers personally or can assign a third party to vet for them. - GT is paid by the client.
### * After the client selects the freelancer the proposal is finalized by putting the agreed upon bounty amount into the contract.
### *Client can end the contract after work is done, the payment is then released to the freelancer.
### *Hourly payments will be introduced. For the sake of simplicity the first version of this project will have only milestone based payments.
### *Client-freelancer disputes are to be handled by the assigned third party. A freelancer/client address can be blacklisted after it has been flagged by three or more assigned third parties.
### *2.5% of the bounty is acquired by the assigned third party.

## Freelancer-side features
### * Freelancers can apply for proposals available and can also counter with a different bounty amount. They can type out counter proposals that are available to the both the client and the assigned third party.
### * To accept an offer from a client the freelancer must put up 10% of the bounty amount. This 10% is placed in escrow and is supposed to go to the assigned third party on completion of the contract.
### * If the work is completed without issue, the client initializes payment and the escrow amount goes to the freelancer. Of the 10% staked by the freelancer, 5% goes to the assigned third party and 5% goes back to the freelancer.
### * In case of a dispute, the assigned third party is delegated to resolve it and acquires the entire 10% of the freelancer stake.

### Percentage amounts acquired by third parties will be capped at a certain amount.