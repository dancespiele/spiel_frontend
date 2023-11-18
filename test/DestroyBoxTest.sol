// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, StdUtils} from "forge-std/Test.sol";
import {DestroyBox} from "../src/DestroyBox.sol";
import {IERC20} from "@chainlink/contracts-ccip/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import "@chainlink/contracts/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract DestroyBoxTest is Test {
    DestroyBox public destroyBox;

    address owner = 0x2Ac9180390a96FBc9532384E13E96ba7CB427403;
    address user = 0xF91d149BE554304DDD391937f9DcF57341cFAf02;
    address linkToken = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;

    function setUp() public {
        vm.startPrank(owner);

        destroyBox = new DestroyBox(761, 78000000000000000);

        VRFCoordinatorV2Interface(0x2eD832Ba664535e5886b75D64C46EB9a228C2610).addConsumer(761, address(destroyBox));

        vm.stopPrank();
    }

    function testBoxToDestroy() public {
        vm.startPrank(user);
        deal(linkToken, user, 1 ether);

        IERC20(linkToken).approve(address(destroyBox), 1 ether);

        uint256 previous_tokens_amount = IERC20(linkToken).balanceOf(address(destroyBox));

        destroyBox.rollDice();

        uint256 current_tokens_amount = IERC20(linkToken).balanceOf(address(destroyBox));

        vm.stopPrank();
        assertTrue(VRFCoordinatorV2Interface(0x2eD832Ba664535e5886b75D64C46EB9a228C2610).pendingRequestExists(761));
        assertTrue(previous_tokens_amount < current_tokens_amount);
    }
}
