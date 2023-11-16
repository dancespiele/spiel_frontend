// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IRouterClient} from "@chainlink/contracts-ccip/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {WAVAX} from "wrapped-assets/WAVAX.sol";

contract CCIPSendTokens is CCIPReceiver, OwnerIsCreator {
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
    error NothingToWithdraw();
    error FailedToWithdrawEth(address owner, address target, uint256 value);
    error DestinationChainNotAllowed(uint64 destinationChainSelector);
    error SourceChainNotAllowed(uint64 sourceChainSelector);
    error SenderNotAllowed(address sender);

    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string text,
        address token,
        uint256 tokenAmount,
        address feeToken,
        uint256 fees
    );

    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address senser,
        string text,
        address token,
        uint256 tokenAmount
    );

    bytes32 private s_lastReceivedMessageId;
    address private s_lastReceivedTokenAddress;
    uint256 private s_lastReceivedTokenAmount;
    string private s_lastReceivedText;
    address private platform;

    mapping(uint64 => bool) public allowListedDestinationChains;

    mapping(uint64 => bool) public allowListedSourceChains;

    IERC20 private s_linkToken;

    WAVAX private w_nativeToken;

    constructor(address _router, address _link, address _nativeToken, address _platform) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
        w_nativeToken = WAVAX(payable(_nativeToken));
        platform = _platform;
    }

    modifier onlyAllowListedDestionationChain(uint64 _destinationChainSelector) {
        if (!allowListedDestinationChains[_destinationChainSelector]) {
            revert DestinationChainNotAllowed(_destinationChainSelector);
        }
        _;
    }

    modifier onlyAllowListedSourceChain(uint64 _sourceChainSelector) {
        if (!allowListedSourceChains[_sourceChainSelector]) {
            revert SourceChainNotAllowed(_sourceChainSelector);
        }
        _;
    }

    function allowListDestinationChain(uint64 _destinationChainSelector, bool allowed) external onlyOwner {
        allowListedDestinationChains[_destinationChainSelector] = allowed;
    }

    function allowListSourceChain(uint64 _sourceChainSelector, bool allowed) external onlyOwner {
        allowListedDestinationChains[_sourceChainSelector] = allowed;
    }

    function _buildCCIPMessage(
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: _token, amount: _amount});

        return Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_text),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false})),
            feeToken: _feeTokenAddress
        });
    }

    function getFeePrediction(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token_fees,
        address _token,
        uint256 _amount
    ) public view onlyAllowListedDestionationChain(_destinationChainSelector) returns (uint256) {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(_receiver, _text, _token, _amount, _token_fees);

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        return fees + (fees / 10);
    }

    function sendTokenPayLink(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount
    ) external onlyAllowListedDestionationChain(_destinationChainSelector) returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory evm2AnyMessage =
            _buildCCIPMessage(_receiver, _text, _token, _amount, address(s_linkToken));

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this))) {
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }

        if (_amount > IERC20(_token).balanceOf(address(this))) {
            revert NotEnoughBalance(IERC20(_token).balanceOf(address(this)), _amount);
        }

        if (fees + (fees / 10) > s_linkToken.balanceOf(msg.sender)) {
            revert NotEnoughBalance(s_linkToken.balanceOf(msg.sender), fees + (fees / 10));
        }

        if (_amount > IERC20(_token).balanceOf(msg.sender)) {
            revert NotEnoughBalance(IERC20(_token).balanceOf(msg.sender), _amount);
        }

        s_linkToken.approve(address(router), fees);

        IERC20(_token).approve(address(router), _amount);

        s_linkToken.transferFrom(msg.sender, platform, fees / 10);
        s_linkToken.transferFrom(msg.sender, address(this), fees);
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        emit MessageSent(
            messageId, _destinationChainSelector, _receiver, _text, _token, _amount, address(s_linkToken), fees
        );

        return messageId;
    }

    function sendTokenPayNative(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount
    ) external onlyAllowListedDestionationChain(_destinationChainSelector) returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(_receiver, _text, _token, _amount, address(0));

        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > address(this).balance) {
            revert NotEnoughBalance(address(this).balance, fees);
        }

        if (_amount > IERC20(_token).balanceOf(address(this))) {
            revert NotEnoughBalance(IERC20(_token).balanceOf(address(this)), _amount);
        }

        if (fees + (fees / 10) > w_nativeToken.balanceOf(msg.sender)) {
            revert NotEnoughBalance(w_nativeToken.balanceOf(msg.sender), fees + (fees / 10));
        }

        if (_amount > IERC20(_token).balanceOf(msg.sender)) {
            revert NotEnoughBalance(IERC20(_token).balanceOf(msg.sender), _amount);
        }

        IERC20(_token).approve(address(router), _amount);

        w_nativeToken.transferFrom(msg.sender, platform, fees / 10);
        w_nativeToken.transferFrom(msg.sender, address(this), fees);
        w_nativeToken.withdraw(fees);
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        messageId = router.ccipSend{value: fees}(_destinationChainSelector, evm2AnyMessage);

        emit MessageSent(messageId, _destinationChainSelector, _receiver, _text, _token, _amount, address(0), fees);

        return messageId;
    }

    function getLastReceivedMessageDetails()
        public
        view
        returns (bytes32 messageId, string memory text, address tokenAddress, uint256 tokenAmount)
    {
        return (s_lastReceivedMessageId, s_lastReceivedText, s_lastReceivedTokenAddress, s_lastReceivedTokenAmount);
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage)
        internal
        override
        onlyAllowListedSourceChain(any2EvmMessage.sourceChainSelector)
    {
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

    function withdraw(address _beneficiary) public onlyOwner {
        uint256 amount = address(this).balance;

        if (amount == 0) revert NothingToWithdraw();

        (bool sent,) = _beneficiary.call{value: amount}("");

        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }
}
