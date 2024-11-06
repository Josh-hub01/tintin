// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.24;

import 'forge-std-1.9.3/src/Test.sol';
import '@openzeppelin-contracts-5.0.2/utils/Strings.sol';

import {Voting} from 'src/Voting.sol';

contract TestWETH is Test {
  Voting voting;
  address owner;
  address voter1;
  address voter2;
  address voter3;

  function setUp() public {
    owner = makeAddr('Alice');
    voter1 = makeAddr('Bob');
    voter2 = makeAddr('Carol');
    voter3 = makeAddr('Dave');

    // 假设这是你想要传递的字符串数组
    string[] memory stringArray = new string[](3);
    stringArray[0] = 'a';
    stringArray[1] = 'b';
    stringArray[2] = 'c';

    // 将字符串数组转换为bytes32数组
    bytes32[] memory bytes32Array = new bytes32[](3);
    for (uint256 i = 0; i < stringArray.length; i++) {
      bytes32Array[i] = bytes32(abi.encodePacked(stringArray[i]));
    }

    // 使用bytes32数组来初始化Voting合约
    voting = new Voting(bytes32Array);
  }

  // test vote
  function testVote() public {
    voting.giveRightToVote(voter1);
    voting.giveRightToVote(voter2);
    voting.giveRightToVote(voter3);

    // 获取当前时间戳
    uint256 currentTime = block.timestamp;
    // 假设我们想要将时间推进到 4 天后
    uint256 fourDaysLater = currentTime + 4 days;

    // 使用 vm.warp 函数来修改时间戳
    vm.warp(fourDaysLater);

    assertEq(block.timestamp, fourDaysLater);

    vm.prank(voter1);
    voting.vote(0);

    vm.prank(voter2);
    voting.vote(1);

    vm.prank(voter3);
    voting.vote(1);

    assertEq(voting.winningProposal(), 1);
  }
  
  // test set voter weight
  function testSetVoterWeight() public {
    voting.giveRightToVote(voter1);
    voting.giveRightToVote(voter2);
    voting.giveRightToVote(voter3);

    // 获取当前时间戳
    uint256 currentTime = block.timestamp;
    // 假设我们想要将时间推进到 4 天后
    uint256 fourDaysLater = currentTime + 4 days;

    // 使用 vm.warp 函数来修改时间戳
    vm.warp(fourDaysLater);
    assertEq(block.timestamp, fourDaysLater);

    vm.prank(voter2);
    voting.vote(1);

    vm.prank(voter3);
    voting.vote(1);

    // 设置 voter1 的权重为 3
    voting.setVoterWeight(voter1, 3);

    vm.prank(voter1);
    voting.vote(0);

    assertEq(voting.winningProposal(), 0);
  }
}
