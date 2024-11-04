// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MemeXProxy is TransparentUpgradeableProxy {
    address private _owner;

    constructor(
        address _memexday,
        address _initialOwner,
        bytes memory _data
    )
        TransparentUpgradeableProxy(_memexday, _initialOwner, _data)
    {}

    function owner() external view returns (address) {
        return _owner;
    }

    function proxyAdmin() external returns (address) {
        return _proxyAdmin();
    }

    receive() external payable {}
}
