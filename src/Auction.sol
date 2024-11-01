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

  mapping(address => uint) public lastBidTimes;
  uint public cooldownTime = 10 minutes;
  uint public extendedTime = 5 minutes;
  uint public extensionThreshold = 5 minutes;
  uint public finalBidWindow = 5 minutes;

  event BidIncreased(address bidder, uint amount);
  event AuctionEnded(address winner, uint highestBid);

  error AuctionAlreadyEnded();
  error BidNotHighEnough(uint highestBid);
  error CooldownPeriodNotEnded(uint prevTime);
  error AuctionNotYetEnded();
  error AuctionEndAlreadyCalled();
  error TooLate(uint time);

  modifier onlyBefore(uint time) {
    if (block.timestamp >= time) {
      revert TooLate(time);
    }
    _;
  }

  constructor(uint auctionDuration_, address payable beneficiary_) {
    beneficiary = beneficiary_;
    auctionEndTime = block.timestamp + auctionDuration_;
  }

  function bid() public payable onlyBefore(auctionEndTime) {
    uint lastBidTime = lastBidTimes[msg.sender];

    if (lastBidTime != 0 && (block.timestamp < lastBidTime + cooldownTime)) {
      revert CooldownPeriodNotEnded(lastBidTime);
    }

    uint currentBid = calculateBid(highestBid);

    // Update the previous cooldown time for the sender
    lastBidTimes[msg.sender] = block.timestamp;

    if (highestBid != 0) {
      pendingReturns[highestBidder] += highestBid;
    }

    highestBidder = msg.sender;
    highestBid = currentBid;
    emit BidIncreased(msg.sender, msg.value);

    // Extend the auction time if it's within the last extension period
    if (block.timestamp >= auctionEndTime - extensionThreshold) {
      auctionEndTime += extendedTime;
    }
  }

  function calculateBid(uint bidAmount) internal view returns (uint) {
    bool isInFinalBidWindow = block.timestamp >= auctionEndTime - finalBidWindow;
    uint currentBid = msg.value;

    // Apply a 10% increase to the bid amount
    if (isInFinalBidWindow) {
      currentBid = (msg.value * 110) / 100;
    }

    if (currentBid <= bidAmount) {
      revert BidNotHighEnough(bidAmount);
    }

    return currentBid;
  }

  function withdraw() external returns (bool) {
    uint amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
      return true;
    }
    return false;
  }

  function finalizeAuction() external {
    if (block.timestamp < auctionEndTime) {
      revert AuctionNotYetEnded();
    }

    if (ended) {
      revert AuctionEndAlreadyCalled();
    }

    ended = true;
    emit AuctionEnded(highestBidder, highestBid);

    beneficiary.transfer(highestBid);
  }
}
