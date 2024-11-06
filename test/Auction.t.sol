// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std-1.9.3/src/Test.sol';
import {Auction} from 'src/Auction.sol';

contract AuctionTest is Test {
  Auction auction;
  address payable beneficiary;
  uint public auctionDuration;

  function setUp() public {
    beneficiary = payable(makeAddr('Alice'));
    auctionDuration = 20 minutes;
    auction = new Auction(auctionDuration, beneficiary);
  }

  function testAuctionSuccess() public {
    address bidder1 = makeAddr('Bob');
    address bidder2 = makeAddr('Carol');
    address bidder3 = makeAddr('Dave');

    vm.deal(bidder1, 1 ether);
    vm.deal(bidder2, 2 ether);
    vm.deal(bidder3, 3 ether);

    vm.prank(bidder1);
    auction.bid{value: bidder1.balance}();

    vm.prank(bidder2);
    auction.bid{value: bidder2.balance}();

    vm.prank(bidder3);
    auction.bid{value: bidder3.balance}();

    assertEq(auction.highestBid(), 3 ether);
    assertEq(auction.highestBidder(), bidder3);

    vm.warp(block.timestamp + 1 hours);
    auction.endAuction();
    assertEq(beneficiary.balance, 3 ether);

    assertEq(bidder1.balance, 0);
    vm.prank(bidder1);
    auction.withdraw();
    assertEq(bidder1.balance, 1 ether);
  }

  function testWeighted() public {
    address bidder1 = makeAddr('Bob');
    address bidder2 = makeAddr('Carol');

    vm.deal(bidder1, 1 ether);
    vm.deal(bidder2, 0.95 ether);

    vm.prank(bidder1);
    auction.bid{value: bidder1.balance}();

    vm.warp(block.timestamp + 15 minutes);
    vm.prank(bidder2);
    auction.bid{value: bidder2.balance}();

    assertEq(auction.highestBidder(), bidder2);
  }

  function testCooldownPeriod() public {
    address bidder1 = makeAddr('Bob');

    vm.deal(bidder1, 2 ether);

    vm.prank(bidder1);
    auction.bid{value: 1 ether}();

    vm.expectPartialRevert(Auction.CooldownPeriodNotEnded.selector);
    vm.prank(bidder1);
    auction.bid{value: 1 ether}();
  }

  function testExtendAuctionTime() public {
    address bidder1 = makeAddr('Bob');
    vm.deal(bidder1, 2 ether);

    uint defaultAuctionEndTime = auction.auctionEndTime();

    vm.warp(block.timestamp + 15 minutes);
    vm.prank(bidder1);
    auction.bid{value: 1 ether}();

    vm.warp(block.timestamp + 5 minutes);
    vm.expectPartialRevert(Auction.AuctionNotYetEnded.selector);
    auction.endAuction();
    assertGt(auction.auctionEndTime(), defaultAuctionEndTime);
  }
}
