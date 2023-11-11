// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FeedTokensPrice} from "../src/FeedTokensPrice.sol";

contract FeedTokensPriceTest is Test {
    FeedTokensPrice public feedTokensPrice;

    function setUp() public {
        feedTokensPrice = new FeedTokensPrice(
            0x34C4c526902d88a3Aa98DB8a9b802603EB1E3470, 
            0x71b95cEA998831C28Eb7FF0AbFC80564C38Cf5A8,
            0x31CF013A08c6Ac228C94551d535d5BAfE19c602a,
            0x86d67c3D38D2bCeE722E601025C25a575021c6EA,
            0xB0924e98CAFC880ed81F6A4cA63FD61006D1f8A0,
            0x996684D3B879E4193e4678D2C276F8B000cd533B
        );
    }

    function test_GetListPrice() public {
        FeedTokensPrice.PriceList memory price_list = feedTokensPrice.getPriceList();

        assertTrue(price_list.link > 0);
        assertTrue(price_list.aave > 0);
        assertTrue(price_list.btc > 0);
        assertTrue(price_list.eth > 0);
        assertTrue(price_list.matic > 0);
        assertTrue(price_list.ape > 0);
    }
}
