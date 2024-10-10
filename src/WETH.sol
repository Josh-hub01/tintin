// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin-contracts-5.0.2/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin-contracts-5.0.2/access/Ownable.sol";

contract WETH is ERC20, Ownable {
    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);

    constructor() ERC20("Wrapped Ether", "WETH") Ownable(msg.sender) {}

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount_) external {
        require(amount_ > 0, "Withdraw amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount_, "Insufficient balance");

        _burn(msg.sender, amount_);
        transfer(msg.sender, amount_);

        emit Withdraw(msg.sender, amount_);
    }

    // receive() external payable {
    //     deposit();
    // }
}
