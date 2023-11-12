// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@chainlink/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * Get the prices of tokens added in the contract
 * @title FeeTokensPrice
 * @author Francisco Jesús Navarro Cortés
 */
contract FeedTokensPrice {
    address[] address_list;
    address s_owner;

    /**
     * set up the contract with the supported token address
     * @param tokens token suppoted
     */
    constructor(address[] memory tokens) {
        address_list = tokens;
        s_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only owner can execute this contract method");
        _;
    }

    function getPriceList() public view returns (int256[] memory) {
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

        return prices;
    }

    function addContractPrice(address token) external onlyOwner {
        address_list.push(token);
    }

    function removeContractPrice(address token) external onlyOwner {
        for (uint256 i = 0; i < address_list.length; i++) {
            if (address_list[i] == token) {
                for (uint256 j = i; j < address_list.length - 1; j++) {
                    address_list[j] = address_list[j + 1];
                }

                address_list.pop();
                break;
            }
        }
    }

    function getAggregator(address token) private pure returns (AggregatorV3Interface) {
        return AggregatorV3Interface(token);
    }
}
