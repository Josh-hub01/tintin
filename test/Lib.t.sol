// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';

import {Lib} from '../src/Lib.sol';

contract LibTest is Test {
  Lib lib;
  uint[] arr;

  function setUp() public {
    lib = new Lib();
  }

  function test_Sort() public {
    arr.push(4);
    arr.push(1);
    arr.push(2);
    arr.push(3);

    uint[] memory arrMemory = new uint[](arr.length);
    for (uint i = 0; i < arr.length; i++) {
      arrMemory[i] = arr[i];
    }

    uint[] memory sortedArr = lib.insertionSort(arrMemory);
    assertEq(sortedArr[0], 1);
    assertEq(sortedArr[1], 2);
    assertEq(sortedArr[2], 3);
    assertEq(sortedArr[3], 4);
  }
}
