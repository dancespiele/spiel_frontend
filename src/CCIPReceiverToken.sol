// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {Client} from "@chainlink/contracts-ccip/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/v0.8/ccip/applications/CCIPReceiver.sol";

contract CCIPReceiverToken is CCIPReceiver {
    bytes32 private s_lastReceivedMessageId;
    address private s_lastReceivedTokenAddress;
    uint256 private s_lastReceivedTokenAmount;
    string private s_lastReceivedText;

    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address senser,
        string text,
        address token,
        uint256 tokenAmount
    );

    constructor(address router) CCIPReceiver(router) {}

    function getLastReceivedMessageDetails()
        public
        view
        returns (bytes32 messageId, string memory text, address tokenAddress, uint256 tokenAmount)
    {
        return (s_lastReceivedMessageId, s_lastReceivedText, s_lastReceivedTokenAddress, s_lastReceivedTokenAmount);
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId;
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string));
        s_lastReceivedTokenAddress = any2EvmMessage.destTokenAmounts[0].token;
        s_lastReceivedTokenAmount = any2EvmMessage.destTokenAmounts[0].amount;

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            abi.decode(any2EvmMessage.data, (string)),
            any2EvmMessage.destTokenAmounts[0].token,
            any2EvmMessage.destTokenAmounts[0].amount
        );
    }

    receive() external payable {}
}
