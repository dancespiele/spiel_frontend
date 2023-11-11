// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@chainlink/v0.8/interfaces/AggregatorV3Interface.sol";

contract FeedTokensPrice {
    struct PriceList {
        int256 link;
        int256 aave;
        int256 btc;
        int256 eth;
        int256 matic;
        int256 ape;
    }

    address[] address_list;

    constructor(address link, address aave, address btc, address eth, address matic, address ape) {
        address_list = [link, aave, btc, eth, matic, ape];
    }

    function getPriceList() public view returns (PriceList memory) {
        int256[] memory prices = new int256[](address_list.length);
        for (uint256 i = 0; i < address_list.length; i++) {
            AggregatorV3Interface dataFeed = getAggregator(address_list[i]);
            (
                /*uint80 roundID*/
                ,
                int256 answer,
                /*uint startedAt*/
                ,
                /*uint timeStamp*/
                ,
                /*uint80 answeredInRound*/
            ) = dataFeed.latestRoundData();

            prices[i] = answer;
        }

        return fillPriceList(prices);
    }

    function fillPriceList(int256[] memory list) private pure returns (PriceList memory) {
        return PriceList(list[0], list[1], list[2], list[3], list[4], list[5]);
    }

    function getAggregator(address token) private pure returns (AggregatorV3Interface) {
        return AggregatorV3Interface(token);
    }
}
