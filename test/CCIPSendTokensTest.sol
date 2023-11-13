// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, StdUtils} from "forge-std/Test.sol";
import {CCIPSendTokens} from "../src/CCIPSendTokens.sol";
import {IERC20} from "@chainlink/contracts-ccip/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

contract CCIPSendTokensTest is Test {
    CCIPSendTokens ccipSendTokens;
    address owner = 0x2Ac9180390a96FBc9532384E13E96ba7CB427403;
    address user = 0xF91d149BE554304DDD391937f9DcF57341cFAf02;
    address userReceiver = 0x2fA4388135365DAF770f7B4e8C0A93b12654918C;

    function setUp() public {
        vm.prank(owner);

        ccipSendTokens =
        new CCIPSendTokens(0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, 0xd00ae08403B9bbb9124bB305C09058E32C39A48c, 0x2Ac9180390a96FBc9532384E13E96ba7CB427403);
    }

    function testSendLinkTokens() public {
        bytes32 empty;

        vm.startPrank(owner);

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, address(ccipSendTokens), 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, user, 1 ether);
        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, user, 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, address(ccipSendTokens), 1 ether);

        vm.startPrank(user);

        bytes32 messageId = ccipSendTokens.sendTokenPayLink(
            12532609583862916517, userReceiver, "send crypto", 0x70F5c5C40b873EA597776DA2C21929A8282A3b35, 10000000
        );

        vm.stopPrank();

        assertTrue(messageId != empty);
    }
}
