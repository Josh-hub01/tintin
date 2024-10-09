// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.24;

import "forge-std-1.9.3/src/Test.sol";
import "@openzeppelin-contracts-5.0.2/utils/Strings.sol";

import "src/WETH.sol";

contract TestWETH is Test {
    WETH weth;
    address owner;

    function setUp() public {
        owner = makeAddr("Alice");

        vm.deal(owner, 2 ether);

        weth = new WETH();
    }

    function testWidthdraw() public {
        vm.startPrank(owner);

        weth.deposit{value: 2 ether}();
        assertEq(weth.balanceOf(owner), 2 ether);

        weth.withdraw(1 ether);
        assertEq(weth.balanceOf(owner), 1 ether);

        vm.stopPrank();
    }
}
