// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {
  address payable public beneficiary;
  uint public auctionEnd;
  address public highestBidder;
  uint public highestBid;
  mapping(address => uint) public pendingReturns;
  bool ended;

  event HighestBidIncreased(address bidder, uint amount);
  event AuctionEnded(address winner, uint amount);

  constructor(
    uint biddingTime_,
    address payable beneficiary_
  ) {
    beneficiary = beneficiary_;
    auctionEnd = block.timestamp + biddingTime_;
  }

  function bid() public payable {
    require(block.timestamp <= auctionEnd, "Auction already ended");
    require(msg.value > highestBid, "There already is a higher bid");

    if (highestBid!= 0) {
      pendingReturns[highestBidder] += highestBid;
    }
    highestBid = msg.value;
    highestBidder = msg.sender;
    emit HighestBidIncreased(msg.sender, msg.value);
  }

  function withdraw() public returns (bool) {
    uint amount = pendingReturns[msg.sender];
    if (amount > 0) {
      pendingReturns[msg.sender] = 0;
      payable(msg.sender).transfer(amount);
    }
    return true;
  }

  function endAuction() public {
    require(block.timestamp >= auctionEnd, "Auction has not ended yet");
    require(!ended, "Auction has already ended");

    ended = true;
    emit AuctionEnded(highestBidder, highestBid);
    beneficiary.transfer(highestBid);
  }
}
