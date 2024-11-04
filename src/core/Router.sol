// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../token/ERC20.sol";
import "./Factory.sol";
import "./Pair.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Router is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    uint256 public constant BASIS_POINTS_DIVISOR = 10000;

    address private _factory;

    address private _WGAS;

    address private _master;

    event MasterUpdated(address indexed master);

    error InvalidAddress();
    error InvalidMaster();
    error InvalidReceiver();
    error InvalidToken();

    constructor(address factory_, address wgas) Ownable(msg.sender) {
        if (factory_ == address(0)) {
            revert InvalidAddress();
        }
        if (wgas == address(0)) {
            revert InvalidAddress();
        }

        _factory = factory_;

        _WGAS = wgas;
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                       ACCESS CONTROL                       *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    modifier onlyMaster() {
        if (msg.sender != _master) {
            revert InvalidMaster();
        }
        _;
    }

    function setMaster(address _newMaster) external onlyOwner {
        if (_newMaster == address(0)) {
            revert InvalidAddress();
        }
        _master = _newMaster;
        emit MasterUpdated(_master);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           GETTER                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function factory() public view returns (address) {
        return _factory;
    }

    function WGAS() public view returns (address) {
        return _WGAS;
    }

    function _getAmountsOut(address token, address wgas, uint256 amountIn) private view returns (uint256 _amountOut) {
        require(token != address(0), "Zero addresses are not allowed.");

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        (, uint256 _reserveA,, uint256 _reserveB) = _pair.getReserves();

        uint256 k = _pair.kLast();

        uint256 amountOut;

        if (wgas == _WGAS) {
            uint256 newReserveB = _reserveB + amountIn;

            uint256 newReserveA = k / newReserveB;

            amountOut = _reserveA - newReserveA;
        } else {
            uint256 newReserveA = _reserveA + amountIn;

            uint256 newReserveB = k / newReserveA;

            amountOut = _reserveB - newReserveB;
        }

        return amountOut;
    }

    function getAmountsOut(
        address token,
        address wgas,
        uint256 amountIn
    )
        external
        nonReentrant
        returns (uint256 _amountOut)
    {
        uint256 amountOut = _getAmountsOut(token, wgas, amountIn);

        return amountOut;
    }

    function _validateTokenAndTo(address tk, address to) internal pure {
        if (tk == address(0)) {
            revert InvalidToken();
        }
        if (to == address(0)) {
            revert InvalidReceiver();
        }
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                       UPDATE LIQUIDITY                     *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function transferETH(address _address, uint256 amount) private returns (bool) {
        require(_address != address(0), "Zero addresses are not allowed.");

        (bool os,) = payable(_address).call{value: amount}("");

        return os;
    }

    function _addLiquidityETH(
        address token,
        uint256 amountToken,
        uint256 amountETH
    )
        private
        returns (uint256, uint256)
    {
        require(token != address(0), "Zero addresses are not allowed.");

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        IERC20 token_ = IERC20(token);

        {
            bool os = transferETH(pair, amountETH);
            require(os, "Transfer of ETH to pair failed.");
        }

        bool os1 = token_.transferFrom(msg.sender, pair, amountToken);
        require(os1, "Transfer of token to pair failed.");

        _pair.mint(amountToken, amountETH, msg.sender);

        return (amountToken, amountETH);
    }

    function addLiquidityETH(
        address token,
        uint256 amountToken
    )
        external
        payable
        nonReentrant
        onlyMaster
        returns (uint256, uint256)
    {
        uint256 amountETH = msg.value;

        (uint256 amount0, uint256 amount1) = _addLiquidityETH(token, amountToken, amountETH);

        return (amount0, amount1);
    }

    function withdrawTokens(address token, uint256 amountToken, address to) external nonReentrant onlyMaster {
        _validateTokenAndTo(token, to);

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        IERC20 token_ = IERC20(token);

        bool approved = _pair.approval(address(this), token, amountToken);
        require(approved);

        bool os1 = token_.transferFrom(pair, to, amountToken);
        require(os1, "Transfer of token to caller failed.");
    }

    function _removeLiquidityETH(address token, uint256 liquidity, address to) private returns (uint256, uint256) {
        _validateTokenAndTo(token, to);

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        (, uint256 reserveA,,) = _pair.getReserves();

        IERC20 token_ = IERC20(token);

        uint256 amountETH = (liquidity * _pair.balance()) / 100;

        uint256 amountToken = (liquidity * reserveA) / 100;

        bool approved = _pair.approval(address(this), token, amountToken);
        require(approved);

        bool os = _pair.transferETH(to, amountETH);
        require(os, "Transfer of ETH to caller failed.");

        bool os1 = token_.transferFrom(pair, to, amountToken);
        require(os1, "Transfer of token to caller failed.");

        _pair.burn(amountToken, amountETH, msg.sender);

        return (amountToken, amountETH);
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        address to
    )
        external
        nonReentrant
        onlyOwner
        returns (uint256, uint256)
    {
        (uint256 amountToken, uint256 amountETH) = _removeLiquidityETH(token, liquidity, to);

        return (amountToken, amountETH);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                          TOKEN SWAP                        *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function swapTokensForETH(
        uint256 amountIn,
        address token,
        address to
    )
        public
        nonReentrant
        onlyMaster
        returns (uint256, uint256)
    {
        _validateTokenAndTo(token, to);

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        uint256 amountOut;
        {
            IERC20 token_ = IERC20(token);

            amountOut = _getAmountsOut(token, address(0), amountIn);

            bool os = token_.transferFrom(to, pair, amountIn);

            require(os, "Transfer of token to pair failed");
        }

        uint256 txFee;
        {
            uint256 feeBp = factory_.txFeeBp();
            txFee = (feeBp * amountOut) / BASIS_POINTS_DIVISOR;
        }

        uint256 amount = amountOut - txFee;

        address feeTo = factory_.feeTo();

        {
            bool os2 = _pair.transferETH(to, amount);
            require(os2, "Transfer of ETH to user failed.");
        }

        {
            bool os3 = _pair.transferETH(feeTo, txFee);
            require(os3, "Transfer of ETH to fee address failed.");
        }

        _pair.swap(amountIn, 0, 0, amount);

        return (amountIn, amount);
    }

    function swapETHForTokens(address token, address to) public payable nonReentrant returns (uint256, uint256) {
        _validateTokenAndTo(token, to);

        Factory factory_ = Factory(_factory);

        address pair = factory_.getPair(token, _WGAS);

        Pair _pair = Pair(payable(pair));

        IERC20 token_ = IERC20(token);

        uint256 amountOut = _getAmountsOut(token, _WGAS, msg.value);

        {
            bool approved = _pair.approval(address(this), token, amountOut);
            require(approved, "Not Approved.");
        }

        uint256 feeBp = factory_.txFeeBp();
        uint256 txFee = (feeBp * msg.value) / BASIS_POINTS_DIVISOR;

        uint256 amount;

        amount = msg.value - txFee;

        address feeTo = factory_.feeTo();

        {
            bool os1 = transferETH(pair, amount);
            require(os1, "Transfer of ETH to pair failed.");
        }

        {
            bool os2 = transferETH(feeTo, txFee);
            require(os2, "Transfer of ETH to fee address failed.");
        }

        {
            bool os3 = token_.transferFrom(pair, to, amountOut);
            require(os3, "Transfer of token to pair failed.");
        }

        _pair.swap(0, amountOut, amount, 0);

        return (amount, amountOut);
    }
}
