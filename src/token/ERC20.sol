// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../lib/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;

    uint8 private constant _decimals = 18;

    uint256 private constant _presaleTotalSupply = 1_073_000_191;

    uint256 public constant DEFAULT_MAX_TX = 0;

    uint256 private _tTotal;

    string private _name;

    string private _symbol;

    uint256 public maxTx;

    address public transferRestrictedTo;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private isExcludedFromMaxTx;

    error CannotTransferDuringGame();

    event TransferRestrictionRemoved();

    constructor(string memory name_, string memory symbol_, uint256 _maxTx) Ownable(msg.sender) {
        _name = name_;

        _symbol = symbol_;

        _tTotal = 1073000191 * 10 ** _decimals;

        emit Mint(_msgSender(), _tTotal);

        require(_maxTx <= 100, "Max Transaction cannot exceed 100%.");

        if (_maxTx == 0) {
            maxTx = DEFAULT_MAX_TX;
        } else {
            maxTx = _maxTx;
        }

        _balances[_msgSender()] = _tTotal;

        isExcludedFromMaxTx[_msgSender()] = true;

        isExcludedFromMaxTx[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    //*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
    //*                           GETTER                           *//
    //*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function withdrawLiquidity() public onlyOwner returns (uint256) {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH to withdraw");

        address owner = owner();
        (bool success,) = owner.call{value: contractBalance}("");
        require(success, "Withdrawal failed");

        return contractBalance;
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(msg.sender, to, value);
        _transfer(_msgSender(), to, value);

        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(from, to, value);
        _transfer(from, to, value);

        _approve(
            from, _msgSender(), _allowances[from][_msgSender()].sub(value, "ERC20: transfer amount exceeds allowance")
        );

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (maxTx != 0) {
            uint256 maxTxAmount = (maxTx * _tTotal) / 100;
            if (!isExcludedFromMaxTx[from]) {
                require(amount <= maxTxAmount, "Exceeds the MaxTxAmount.");
            }
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);

        emit Transfer(from, to, amount);
    }

    function updateMaxTx(uint256 _maxTx) public onlyOwner {
        require(_maxTx <= 100, "Max Transaction cannot exceed 100%.");

        maxTx = _maxTx;

        emit MaxTxUpdated(_maxTx);
    }

    function excludeFromMaxTx(address user) public onlyOwner {
        require(user != address(0), "ERC20: Exclude Max Tx from the zero address");

        isExcludedFromMaxTx[user] = true;
    }

    function renounceOwnership() public override(Ownable) onlyOwner {
        super.renounceOwnership();
        if (transferRestrictedTo != address(0)) {
            _removeTransferRestriction();
        }
    }

    function _removeTransferRestriction() internal {
        transferRestrictedTo = address(0);
        emit TransferRestrictionRemoved();
    }

    function _beforeTokenTransfer(address, address to, uint256) internal view {
        if (transferRestrictedTo != address(0) && to == transferRestrictedTo) {
            revert CannotTransferDuringGame();
        }
    }
}
