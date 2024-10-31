// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {
  address payable public beneficiary;
  uint public auctionEndTime;

  // Current state of the auction.
  address public highestBidder;
  uint public highestBid;

  // Allowed withdrawals of previous bids
  mapping(address => uint) public pendingReturns;
  bool ended;

  mapping(address => uint) public prevTimes;
  uint public cooldownTime = 10 minutes;
  uint public extendedTime = 5 minutes;
  uint public startExtendedTime = 5 minutes;

  event HighestBidIncreased(address bidder, uint amount);
  event AuctionEnded(address winner, uint amount);

  error AuctionAlreadyEnded();
  error BidNotHighEnough(uint highestBid);
  error CooldownPeriodNotEnded(uint prevTime);
  error AuctionNotYetEnded();

  constructor(uint biddingTime_, address payable beneficiary_) {
    beneficiary = beneficiary_;
    auctionEndTime = block.timestamp + biddingTime_;
  }

  function bid() external payable {
    if (block.timestamp > auctionEndTime) {
      revert AuctionAlreadyEnded();
    }
    if (msg.value <= highestBid) {
      revert BidNotHighEnough(highestBid);
    }
    if (block.timestamp < (prevTimes[msg.sender] + cooldownTime)) {
      revert CooldownPeriodNotEnded(prevTimes[msg.sender]);
    }

    // Update the previous cooldown time for the sender
    prevTimes[msg.sender] = block.timestamp;

    if (highestBid != 0) {
      pendingReturns[highestBidder] += highestBid;
    }

    highestBid = msg.value;
    highestBidder = msg.sender;
    emit HighestBidIncreased(msg.sender, msg.value);

    // Extend the auction time if it's within the last extension period
    if (block.timestamp >= auctionEndTime - startExtendedTime) {
      auctionEndTime += extendedTime;
    }
  }

  function withdraw() external returns (bool) {
    uint amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
    return true;
  }

  function endAuction() external {
    if (block.timestamp < auctionEndTime) {
      revert AuctionNotYetEnded();
    }

    if (ended) {
      revert AuctionAlreadyEnded();
    }

    ended = true;
    emit AuctionEnded(highestBidder, highestBid);
    
    beneficiary.transfer(highestBid);
  }
}
