// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./Pair.sol";

contract Factory is ReentrancyGuard {
    address private owner;

    address private _feeTo;

    address private _router;

    mapping(address => mapping(address => address)) private pair;

    address[] private pairs;

    uint256 private feeBp = 100;

    event PairCreated(address indexed tokenA, address indexed tokenB, address pair, uint256);
    event FeeToUpdated(address indexed feeTo);
    event FeeBpUpdated(uint256 indexed bp);

    error CannotFeeToZeroAddress();
    error InvalidAddress();
    error InvalidToken();
    error OnlyOwner();

    constructor(address fee_to, uint256 _feeBp) {
        owner = msg.sender;

        if (fee_to == address(0)) {
            revert CannotFeeToZeroAddress();
        }

        feeBp = _feeBp;
        _feeTo = fee_to;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    function setRouter(address router_) external onlyOwner {
        if (router_ == address(0)) {
            revert InvalidAddress();
        }
        _router = router_;
    }

    function _createPair(address tokenA, address tokenB) private returns (address) {
        if (tokenA == address(0)) {
            revert InvalidToken();
        }
        if (tokenB == address(0)) {
            revert InvalidToken();
        }

        Pair _pair = new Pair(address(this), _router, msg.sender, tokenA, tokenB);

        pair[tokenA][tokenB] = address(_pair);
        pair[tokenB][tokenA] = address(_pair);

        pairs.push(address(_pair));

        uint256 n = pairs.length;

        emit PairCreated(tokenA, tokenB, address(_pair), n);

        return address(_pair);
    }

    function createPair(address tokenA, address tokenB) external nonReentrant returns (address) {
        address _pair = _createPair(tokenA, tokenB);

        return _pair;
    }

    function getPair(address tokenA, address tokenB) public view returns (address) {
        return pair[tokenA][tokenB];
    }

    function allPairs(uint256 n) public view returns (address) {
        return pairs[n];
    }

    function allPairsLength() public view returns (uint256) {
        return pairs.length;
    }

    function feeTo() public view returns (address) {
        return _feeTo;
    }

    function feeToSetter() public view returns (address) {
        return owner;
    }

    function setFeeTo(address fee_to) public onlyOwner {
        if (fee_to == address(0)) {
            revert CannotFeeToZeroAddress();
        }

        _feeTo = fee_to;
        emit FeeToUpdated(_feeTo);
    }

    function setFeeBp(uint256 _feeBp) public onlyOwner {
        feeBp = _feeBp;
        emit FeeBpUpdated(_feeBp);
    }

    function txFeeBp() public view returns (uint256) {
        return feeBp;
    }
}
