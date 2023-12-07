// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/v0.8/shared/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/v0.8/vrf/VRFConsumerBaseV2.sol";
import {IERC20} from "@chainlink/contracts-ccip/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

contract DestroyBox is VRFConsumerBaseV2 {
    uint64 s_subscriptionId;
    address s_owner;
    IERC20 s_linkToken = IERC20(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846);
    address linkToken = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    LinkTokenInterface LINKTOKEN;
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;
    bytes32 s_keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmation = 3;
    uint32 numWords = 1;
    uint256 private constant ROLL_IN_PROGRESS = 42;
    uint256 s_platformFees;

    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);

    mapping(uint256 => address) private s_rollers;
    mapping(address => uint256) private s_results;

    constructor(uint64 subscriptionId, uint256 platformFees) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        s_platformFees = platformFees;
        LINKTOKEN = LinkTokenInterface(linkToken);
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    function rollDice() public returns (uint256 requestId) {
        require(s_results[msg.sender] != ROLL_IN_PROGRESS, "Player has a roll in progess");
        require(s_platformFees < s_linkToken.balanceOf(msg.sender), "Not enough balance to generate random number");

        requestId =
            COORDINATOR.requestRandomWords(s_keyHash, s_subscriptionId, requestConfirmation, callbackGasLimit, numWords);

        s_rollers[requestId] = msg.sender;
        s_results[msg.sender] = ROLL_IN_PROGRESS;

        s_linkToken.transferFrom(msg.sender, address(this), s_platformFees);

        emit DiceRolled(requestId, msg.sender);

        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 d20Value = (randomWords[0] % 20) + 1;

        s_results[s_rollers[requestId]] = d20Value;

        emit DiceLanded(requestId, d20Value);
    }

    function boxToDestroy() public view returns (uint256) {
        require(s_results[msg.sender] != 0, "Dice not rolled");

        require(s_results[msg.sender] != ROLL_IN_PROGRESS, "Roll in progess");

        return s_results[msg.sender];
    }

    function topUpSubscription(uint256 amount) external onlyOwner {
        LINKTOKEN.transferAndCall(address(COORDINATOR), amount, abi.encode(s_subscriptionId));
    }

    function withdraw(uint256 amount, address to) external onlyOwner {
        LINKTOKEN.transfer(to, amount);
    }

    function setFees(uint256 amount) external onlyOwner {
        s_platformFees = amount;
    }
}
