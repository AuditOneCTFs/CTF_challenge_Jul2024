pragma solidity ^0.8.24;

import 'forge-std/Test.sol';
import 'src/Message.sol';
import {USDC} from 'src/ERC20/USDC.sol';

contract Tester is Test {

    address user = makeAddr("user");
    address admin;
    uint256 adminPk;

    RewardCTF rewardCTF;
    USDC usdc;
    bytes signature;
    uint256 rewardAmount = 1000e6;
    uint256 expiry = 365 days;

    function setUp() public {
        (admin, adminPk) = makeAddrAndKey("admin");
        usdc = new USDC("USDC", "USDC");
        rewardCTF = new RewardCTF(admin, address(usdc));
        usdc.mint(address(rewardCTF), 2000e6);
        bytes32 messageHash = keccak256(abi.encode(user, rewardAmount, expiry));
        messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(adminPk, messageHash);
        signature = abi.encodePacked(r,s,v);
    }

    modifier userDoes {
        vm.startPrank(user);
        _;
        vm.stopPrank();
    }

    function test_solution() public userDoes {
        rewardCTF.claim(rewardAmount, expiry, signature);
        assertEq(usdc.balanceOf(user), rewardAmount);

        //Write in here you solution

        // This asserts need to pass to solve the CTF
        assertEq(usdc.balanceOf(user), rewardAmount*2);
        assertEq(usdc.balanceOf(address(rewardCTF)), 0);
    }
}