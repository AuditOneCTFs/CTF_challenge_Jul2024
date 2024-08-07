// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import 'lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract USDC is ERC20 {

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address account, uint256 value) external {
        _mint(account, value);
    }
}