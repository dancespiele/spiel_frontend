// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FeedTokensPrice} from "../src/FeedTokensPrice.sol";

contract FeedTokensPriceTest is Test {
    FeedTokensPrice public feedTokensPrice;
    address owner = 0x2Ac9180390a96FBc9532384E13E96ba7CB427403;
    address user = 0xF91d149BE554304DDD391937f9DcF57341cFAf02;

    function setUp() public {
        vm.prank(owner);
        address[] memory tokens = new address[](6);

        tokens[0] = 0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470;
        tokens[1] = 0x71b95cEA998831C28Eb7FF0AbFC80564C38Cf5A8;
        tokens[2] = 0x31CF013A08c6Ac228C94551d535d5BAfE19c602a;
        tokens[3] = 0x86d67c3D38D2bCeE722E601025C25a575021c6EA;
        tokens[4] = 0xB0924e98CAFC880ed81F6A4cA63FD61006D1f8A0;
        tokens[5] = 0x996684D3B879E4193e4678D2C276F8B000cd533B;

        feedTokensPrice = new FeedTokensPrice(tokens);
    }

    function test_GetListPrice() public {
        int256[] memory price_list = feedTokensPrice.getPriceList();

        for (uint256 i = 0; i < price_list.length; i++) {
            assertTrue(price_list[i] >= 0);
        }
    }

    function test_AddContractPrice() public {
        vm.prank(owner);

        feedTokensPrice.addContractPrice(0x8fb015BE5ddF8ab5AAE9a74A5eCAa8E5EDF1C359);

        int256[] memory price_list = feedTokensPrice.getPriceList();

        assertTrue(price_list.length == 7);
    }

    function test_FailAddContractPrice() public {
        vm.prank(user);
        vm.expectRevert("Only owner can execute this contract method");

        feedTokensPrice.addContractPrice(0xD86A58dAC8eE168D9cedC19d3741Be4811F9B440);
    }

    function test_RemoveContractPrice() public {
        vm.prank(owner);

        feedTokensPrice.removeContractPrice(0x71b95cEA998831C28Eb7FF0AbFC80564C38Cf5A8);

        int256[] memory price_list = feedTokensPrice.getPriceList();

        assertTrue(price_list.length == 5);
    }

    function test_FailRemoveContractPrice() public {
        vm.prank(user);
        vm.expectRevert("Only owner can execute this contract method");

        feedTokensPrice.removeContractPrice(0xD86A58dAC8eE168D9cedC19d3741Be4811F9B440);
    }
}
