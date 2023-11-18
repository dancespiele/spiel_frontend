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
        vm.startPrank(owner);

        ccipSendTokens =
        new CCIPSendTokens(0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, 0xd00ae08403B9bbb9124bB305C09058E32C39A48c, 0x2Ac9180390a96FBc9532384E13E96ba7CB427403);
        vm.stopPrank();
    }

    function testSendLinkTokens() public {
        bytes32 empty;

        vm.startPrank(owner);

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, address(ccipSendTokens), 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, user, 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, user, 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, address(ccipSendTokens), 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokens.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            10000000
        );

        IERC20(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4).approve(address(ccipSendTokens), 10000000);

        IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846).approve(address(ccipSendTokens), fees * 2);

        bytes32 messageId = ccipSendTokens.sendTokenPayLink(
            12532609583862916517, userReceiver, "send crypto", 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, 10000000
        );

        vm.stopPrank();

        assertTrue(messageId != empty);
    }

    function testSendNativeTokens() public {
        bytes32 empty;

        vm.startPrank(owner);

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, address(ccipSendTokens), 1 ether);
        vm.deal(address(ccipSendTokens), 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, user, 1 ether);
        deal(0xd00ae08403B9bbb9124bB305C09058E32C39A48c, user, 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokens.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            10000000
        );

        IERC20(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4).approve(address(ccipSendTokens), 10000000);

        IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokens), fees * 2);

        uint256 previous_native_token = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(owner);

        bytes32 messageId = ccipSendTokens.sendTokenPayNative(
            12532609583862916517, userReceiver, "send crypto", 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, 10000000
        );

        uint256 current_native_token = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(owner);

        vm.stopPrank();

        assertTrue(messageId != empty);
        assertTrue(previous_native_token < current_native_token);
    }

    function testFailNotEnoughNativeTokenFromContract() public {
        vm.startPrank(owner);
        vm.expectRevert("NotEnoughBalance(0, 33422235091170960 [3.342e16])");

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        vm.deal(address(ccipSendTokens), 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, user, 1 ether);
        deal(0xd00ae08403B9bbb9124bB305C09058E32C39A48c, user, 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokens.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            10000000
        );

        IERC20(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4).approve(address(ccipSendTokens), 10000000);

        IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokens), fees * 2);

        (bool revertCCIPSendTokens,) = address(ccipSendTokens).call(
            abi.encodeWithSignature(
                "sendTokenPayNative(uint64 _destinationChainSelector,address _receiver, string calldata _text, address _token, uint256 _amount)",
                "12532609583862916517",
                userReceiver,
                "send crypto",
                0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
                10000000
            )
        );

        assertTrue(revertCCIPSendTokens, "NotEnoughBalance(0, 33422235091170960 [3.342e16])");
    }

    function testFailNotEnoughTokenFromUser() public {
        vm.startPrank(owner);
        vm.expectRevert("NotEnoughBalance(0, 10000000 [1e7])");

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        vm.deal(address(ccipSendTokens), 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, address(ccipSendTokens), 1 ether);
        deal(0xd00ae08403B9bbb9124bB305C09058E32C39A48c, user, 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokens.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            10000000
        );

        IERC20(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4).approve(address(ccipSendTokens), 10000000);

        IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokens), fees * 2);

        (bool revertCCIPSendTokens,) = address(ccipSendTokens).call(
            abi.encodeWithSignature(
                "sendTokenPayNative(uint64 _destinationChainSelector,address _receiver, string calldata _text, address _token, uint256 _amount)",
                "12532609583862916517",
                userReceiver,
                "send crypto",
                0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
                10000000
            )
        );

        assertTrue(revertCCIPSendTokens, "NotEnoughBalance(0, 10000000 [1e7])");
    }

    function testFailNotEnoughWrappedTokenFromUser() public {
        vm.startPrank(owner);
        vm.expectRevert("NotEnoughBalance(0, 33422235091170960 [3.342e16])");

        ccipSendTokens.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        vm.deal(address(ccipSendTokens), 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, address(ccipSendTokens), 1 ether);
        deal(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4, user, 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokens.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            10000000
        );

        IERC20(0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4).approve(address(ccipSendTokens), 10000000);

        IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokens), fees * 2);

        (bool revertCCIPSendTokens,) = address(ccipSendTokens).call(
            abi.encodeWithSignature(
                "sendTokenPayNative(uint64 _destinationChainSelector,address _receiver, string calldata _text, address _token, uint256 _amount)",
                "12532609583862916517",
                userReceiver,
                "send crypto",
                0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
                10000000
            )
        );

        assertTrue(revertCCIPSendTokens, "NotEnoughBalance(0, 33422235091170960 [3.342e16])");
    }

    function testWrapAvax() public {
        vm.startPrank(user);
        vm.deal(user, 5 ether);

        uint256 previous_avax_balance = user.balance;
        uint256 previous_wavax_balance = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(user);

        ccipSendTokens.wrapAvaxToken{value: 1 ether}();

        uint256 current_avax_balance = user.balance;
        uint256 current_wavax_balance = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(user);

        vm.stopPrank();

        assertTrue(current_wavax_balance > previous_wavax_balance);
        assertTrue(current_avax_balance < previous_avax_balance);
    }

    function textUnwrapAvax() public {
        vm.startPrank(user);

        deal(0xd00ae08403B9bbb9124bB305C09058E32C39A48c, user, 5 ether);

        uint256 previous_avax_balance = user.balance;
        uint256 previous_wavax_balance = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(user);

        ccipSendTokens.unwrapAvaxToken(1 ether);

        uint256 current_avax_balance = user.balance;
        uint256 current_wavax_balance = IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).balanceOf(user);

        vm.stopPrank();

        assertTrue(current_avax_balance > previous_avax_balance);
        assertTrue(current_wavax_balance < previous_wavax_balance);
    }
}
