// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../token/ERC20.sol";

contract Pair is ReentrancyGuard {
    receive() external payable {}

    address private _factory;

    address private _router;

    address private _master;

    address private _tokenA;

    address private _tokenB;

    address private lp;

    struct Pool {
        uint256 reserve0;
        uint256 _reserve0;
        uint256 reserve1;
        uint256 _reserve1;
        uint256 k;
        uint256 lastUpdated;
    }

    Pool private pool;

    error InvalidAddress();
    error InvalidMaster();
    error InvalidRouter();
    error InvalidParams();
    error InvalidAmount();
    error InsufficientAmount();

    modifier onlyRouter() {
        if (msg.sender != _router) {
            revert InvalidRouter();
        }
        _;
    }

    modifier onlyMaster() {
        if (msg.sender != _master) {
            revert InvalidMaster();
        }
        _;
    }

    constructor(address factory_, address router_, address master_, address token0, address token1) {
        if (factory_ == address(0) || router_ == address(0) || token0 == address(0) || token1 == address(0)) {
            revert InvalidParams();
        }

        _factory = factory_;

        _router = router_;

        _master = master_;

        _tokenA = token0;

        _tokenB = token1;
    }

    event Mint(uint256 reserve0, uint256 reserve1, address lp);

    event Burn(uint256 reserve0, uint256 reserve1, address lp);

    event Swap(uint256 amount0In, uint256 amount0Out, uint256 amount1In, uint256 amount1Out);

    function mint(uint256 reserve0, uint256 reserve1, address _lp) public onlyRouter returns (bool) {
        lp = _lp;

        pool = Pool({
            reserve0: reserve0,
            _reserve0: MINIMUM_LIQUIDITY0(),
            reserve1: reserve1,
            _reserve1: MINIMUM_LIQUIDITY1(),
            k: MINIMUM_LIQUIDITY0() * MINIMUM_LIQUIDITY1(),
            lastUpdated: block.timestamp
        });

        emit Mint(reserve0, reserve1, _lp);

        return true;
    }

    function swap(
        uint256 amount0In,
        uint256 amount0Out,
        uint256 amount1In,
        uint256 amount1Out
    )
        public
        onlyRouter
        returns (bool)
    {
        uint256 _reserve0 = (pool.reserve0 + amount0In) - amount0Out;
        uint256 reserve0_ = (pool._reserve0 + amount0In) - amount0Out;
        uint256 _reserve1 = (pool.reserve1 + amount1In) - amount1Out;
        uint256 reserve1_ = (pool._reserve1 + amount1In) - amount1Out;

        pool = Pool({
            reserve0: _reserve0,
            _reserve0: reserve0_,
            reserve1: _reserve1,
            _reserve1: reserve1_,
            k: pool.k,
            lastUpdated: block.timestamp
        });

        emit Swap(amount0In, amount0Out, amount1In, amount1Out);

        return true;
    }

    function burn(uint256 reserve0, uint256 reserve1, address _lp) public onlyRouter returns (bool) {
        _validateAddress(_lp);
        require(lp == _lp, "Only Lp holders can call this function.");

        uint256 _reserve0 = pool.reserve0 - reserve0;
        uint256 reserve0_ = pool._reserve0 - reserve0;
        uint256 _reserve1 = pool.reserve1 - reserve1;
        uint256 reserve1_ = pool._reserve1 - reserve1;

        pool = Pool({
            reserve0: _reserve0,
            _reserve0: reserve0_,
            reserve1: _reserve1,
            _reserve1: reserve1_,
            k: pool.k,
            lastUpdated: block.timestamp
        });

        emit Burn(reserve0, reserve1, _lp);

        return true;
    }

    function _approval(address _user, address _token, uint256 amount) private returns (bool) {
        _validateAddress(_user);
        _validateAddress(_token);

        IERC20 token_ = IERC20(_token);

        token_.approve(_user, amount);

        return true;
    }

    function approval(address _user, address _token, uint256 amount) external nonReentrant returns (bool) {
        bool approved = _approval(_user, _token, amount);

        return approved;
    }

    function transferETH(address _address, uint256 amount) public onlyRouter returns (bool) {
        _validateAddress(_address);

        (bool os,) = payable(_address).call{value: amount}("");

        return os;
    }

    function withdrawAllETH(address to) public onlyMaster returns (uint256) {
        _validateAddress(to);

        uint256 balance_ = address(this).balance;
        if (balance_ == 0) {
            return 0;
        }
        (bool os,) = payable(to).call{value: balance_}("");

        require(os, "failed to withdraw ETH");

        return balance_;
    }

    function liquidityProvider() public view returns (address) {
        return lp;
    }

    function MINIMUM_LIQUIDITY0() public pure returns (uint256) {
        return 1_073_000_191 ether;
    }

    function MINIMUM_LIQUIDITY1() public pure returns (uint256) {
        return 30 ether;
    }

    function factory() public view returns (address) {
        return _factory;
    }

    function router() public view returns (address) {
        return _router;
    }

    function master() public view returns (address) {
        return _master;
    }

    function tokenA() public view returns (address) {
        return _tokenA;
    }

    function tokenB() public view returns (address) {
        return _tokenB;
    }

    function getReserves() public view returns (uint256, uint256, uint256, uint256) {
        return (pool.reserve0, pool._reserve0, pool.reserve1, pool._reserve1);
    }

    function kLast() public view returns (uint256) {
        return pool.k;
    }

    function priceALast() public view returns (uint256) {
        return pool.reserve1 / pool.reserve0;
    }

    function priceBLast() public view returns (uint256) {
        return pool.reserve0 / pool.reserve1;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function _validateAddress(address _address) internal pure {
        if (_address == address(0)) {
            revert InvalidAddress();
        }
    }
}
