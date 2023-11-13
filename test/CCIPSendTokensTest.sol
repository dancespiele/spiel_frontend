// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, StdUtils} from "forge-std/Test.sol";
import {CCIPSendTokens} from "../src/CCIPSendTokens.sol";
import {IERC20} from "@chainlink/contracts-ccip/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

contract CCIPSendTokensTest is Test {
    CCIPSendTokens ccipSendTokensPolygon;
    CCIPSendTokens ccipSendTokensAvalanche;

    address owner = 0x2Ac9180390a96FBc9532384E13E96ba7CB427403;
    address user = 0xF91d149BE554304DDD391937f9DcF57341cFAf02;
    address userReceiver = 0x2fA4388135365DAF770f7B4e8C0A93b12654918C;
    uint256 forkAvalancheId = vm.createFork("https://api.avax-test.network/ext/bc/C/rpc");
    uint256 forkPoligonId = vm.createFork("https://rpc-mumbai.maticvigil.com");

    function setUp() public {
        vm.startPrank(owner);

        vm.selectFork(forkPoligonId);
        ccipSendTokensPolygon =
        new CCIPSendTokens(0x70499c328e1E2a3c41108bd3730F6670a44595D1, 0x326C977E6efc84E512bB9C30f76E30c160eD06FB, 0x2Ac9180390a96FBc9532384E13E96ba7CB427403);

        vm.selectFork(forkAvalancheId);
        ccipSendTokensAvalanche =
        new CCIPSendTokens(0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8, 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, 0x2Ac9180390a96FBc9532384E13E96ba7CB427403);
        vm.stopPrank();
    }

    function testSendLinkTokens() public {
        bytes32 empty;

        vm.startPrank(owner);

        ccipSendTokensAvalanche.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, address(ccipSendTokensAvalanche), 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, user, 1 ether);
        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, user, 1 ether);
        deal(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846, address(ccipSendTokensAvalanche), 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokensAvalanche.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            0x70F5c5C40b873EA597776DA2C21929A8282A3b35,
            10000000
        );

        IERC20(0x70F5c5C40b873EA597776DA2C21929A8282A3b35).approve(address(ccipSendTokensAvalanche), 10000000);

        IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846).approve(address(ccipSendTokensAvalanche), fees * 2);

        bytes32 messageId = ccipSendTokensAvalanche.sendTokenPayLink(
            12532609583862916517, userReceiver, "send crypto", 0x70F5c5C40b873EA597776DA2C21929A8282A3b35, 10000000
        );

        vm.stopPrank();

        assertTrue(messageId != empty);
    }

    function testSendNativeTokens() public {
        bytes32 empty;

        vm.startPrank(owner);

        ccipSendTokensAvalanche.allowListDestinationChain(12532609583862916517, true);

        vm.stopPrank();

        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, address(ccipSendTokensAvalanche), 1 ether);
        vm.deal(address(ccipSendTokensAvalanche), 1 ether);
        deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, user, 1 ether);

        vm.startPrank(user);

        uint256 fees = ccipSendTokensAvalanche.getFeePrediction(
            12532609583862916517,
            userReceiver,
            "send crypto",
            0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
            0x70F5c5C40b873EA597776DA2C21929A8282A3b35,
            10000000
        );

        IERC20(0x70F5c5C40b873EA597776DA2C21929A8282A3b35).approve(address(ccipSendTokensAvalanche), 10000000);

        IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokensAvalanche), fees * 2);

        bytes32 messageId = ccipSendTokensAvalanche.sendTokenPayNative(
            12532609583862916517, userReceiver, "send crypto", 0x70F5c5C40b873EA597776DA2C21929A8282A3b35, 10000000
        );

        vm.stopPrank();

        assertTrue(messageId != empty);
    }

    // function testReceiveLastMessage() public {
    //     vm.startPrank(owner);

    //     vm.selectFork(forkPoligonId);

    //     ccipSendTokensPolygon.allowListSourceChain(14767482510784806043, true);

    //     vm.selectFork(forkAvalancheId);

    //     ccipSendTokensAvalanche.allowListDestinationChain(12532609583862916517, true);

    //     vm.stopPrank();

    //     deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, address(ccipSendTokensAvalanche), 1 ether);
    //     vm.deal(address(ccipSendTokensAvalanche), 1 ether);
    //     deal(0xd00ae08403B9bbb9124bB305C09058E32C39A48c, user, 1 ether);
    //     deal(0x70F5c5C40b873EA597776DA2C21929A8282A3b35, user, 1 ether);

    //     vm.startPrank(user);

    //     uint256 fees = ccipSendTokensAvalanche.getFeePrediction(
    //         12532609583862916517,
    //         userReceiver,
    //         "send crypto",
    //         0xd00ae08403B9bbb9124bB305C09058E32C39A48c,
    //         0x70F5c5C40b873EA597776DA2C21929A8282A3b35,
    //         10000000
    //     );

    //     IERC20(0x70F5c5C40b873EA597776DA2C21929A8282A3b35).approve(address(ccipSendTokensAvalanche), 10000000);

    //     IERC20(0xd00ae08403B9bbb9124bB305C09058E32C39A48c).approve(address(ccipSendTokensAvalanche), fees * 2);

    //     ccipSendTokensAvalanche.sendTokenPayNative(
    //         12532609583862916517, userReceiver, "send crypto", 0x70F5c5C40b873EA597776DA2C21929A8282A3b35, 10000000
    //     );

    //     vm.selectFork(forkPoligonId);

    //     (, string memory text, address tokenAddress, uint256 tokenAmount) =
    //         ccipSendTokensPolygon.getLastReceivedMessageDetails();

    //     vm.stopPrank();

    //     assertTrue(keccak256(abi.encodePacked(text)) == keccak256(abi.encodePacked("send crypto")));
    //     assertTrue(tokenAddress == 0xc1c76a8c5bFDE1Be034bbcD930c668726E7C1987);
    //     assertTrue(tokenAmount == 10000000);
    // }
}
