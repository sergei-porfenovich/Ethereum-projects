Description of the functioning:

the modifier salelsOn - checks the start of the sale has begun

the modifier collectedAmount - checks the required amount hasn't been collected yet

the modifier checkInvestor - checks if the investor is in a whitelist

the modifier checkDeposit - checks if sent amount fits in the minDeposit and maxDeposit limits
the function getListInvestor -returns the address of the investor at its index

the function getlengthListInvestors - returns the number of investments

the function setWhiteList - adding/removing an investor to/from whitelist

the function getWhiteList - indicates if the address is in the whitelist or not

the function refund - returns to the investors its ethereum and tokens are burned

the function finishCrowdsale - if the softcap is reached,the funds are transferred to the organizer's account, the sale is closed

the function createTokens - receives  funds,issues tokens,if the amount exceeding the hardcap is transferred,the investor will receive change,the funds will immediately be transferred to the organizer's address,the sale is closed
