// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IHooks } from "@balancer-labs/v3-interfaces/contracts/vault/IHooks.sol";
import { IRateProvider } from "@balancer-labs/v3-interfaces/contracts/vault/IRateProvider.sol";
import { IVault } from "@balancer-labs/v3-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v3-interfaces/contracts/vault/VaultTypes.sol";

import { BasePoolFactory } from "../factories/BasePoolFactory.sol";
import { FactoryWidePauseWindow } from "../factories/FactoryWidePauseWindow.sol";
import { PoolConfigBits } from "../lib/PoolConfigLib.sol";
import { PoolMock } from "./PoolMock.sol";

contract PoolFactoryMock is BasePoolFactory {
    uint256 private constant DEFAULT_SWAP_FEE = 0;

    IVault private immutable _vault;

    constructor(
        IVault vault,
        uint32 pauseWindowDuration
    ) BasePoolFactory(vault, pauseWindowDuration, type(PoolMock).creationCode) {
        _vault = vault;
    }

    function createPool(string memory name, string memory symbol) external returns (address) {
        PoolMock newPool = new PoolMock(IVault(address(_vault)), name, symbol);
        _registerPoolWithFactory(address(newPool));
        return address(newPool);
    }

    function registerTestPool(address pool, TokenConfig[] memory tokenConfig) external {
        PoolRoleAccounts memory roleAccounts;

        _vault.registerPool(
            pool,
            tokenConfig,
            DEFAULT_SWAP_FEE,
            getNewPoolPauseWindowEndTime(),
            false,
            roleAccounts,
            address(0), // No hook contract
            _getDefaultLiquidityManagement()
        );
    }

    function registerTestPool(address pool, TokenConfig[] memory tokenConfig, address poolHooksContract) external {
        PoolRoleAccounts memory roleAccounts;

        _vault.registerPool(
            pool,
            tokenConfig,
            DEFAULT_SWAP_FEE,
            getNewPoolPauseWindowEndTime(),
            false,
            roleAccounts,
            poolHooksContract,
            _getDefaultLiquidityManagement()
        );
    }

    function registerTestPool(
        address pool,
        TokenConfig[] memory tokenConfig,
        address poolHooksContract,
        address poolCreator
    ) external {
        PoolRoleAccounts memory roleAccounts;
        roleAccounts.poolCreator = poolCreator;

        _vault.registerPool(
            pool,
            tokenConfig,
            DEFAULT_SWAP_FEE,
            getNewPoolPauseWindowEndTime(),
            false,
            roleAccounts,
            poolHooksContract,
            _getDefaultLiquidityManagement()
        );
    }

    function registerGeneralTestPool(
        address pool,
        TokenConfig[] memory tokenConfig,
        uint256 swapFee,
        uint32 pauseWindowDuration,
        bool protocolFeeExempt,
        PoolRoleAccounts memory roleAccounts,
        address poolHooksContract
    ) external {
        _vault.registerPool(
            pool,
            tokenConfig,
            swapFee,
            uint32(block.timestamp) + pauseWindowDuration,
            protocolFeeExempt,
            roleAccounts,
            poolHooksContract,
            _getDefaultLiquidityManagement()
        );
    }

    function registerPool(
        address pool,
        TokenConfig[] memory tokenConfig,
        PoolRoleAccounts memory roleAccounts,
        address poolHooksContract,
        LiquidityManagement calldata liquidityManagement
    ) external {
        _vault.registerPool(
            pool,
            tokenConfig,
            DEFAULT_SWAP_FEE,
            getNewPoolPauseWindowEndTime(),
            false,
            roleAccounts,
            poolHooksContract,
            liquidityManagement
        );
    }

    function registerPoolWithSwapFee(
        address pool,
        TokenConfig[] memory tokenConfig,
        uint256 swapFeePercentage,
        address poolHooksContract,
        LiquidityManagement calldata liquidityManagement
    ) external {
        PoolRoleAccounts memory roleAccounts;

        _vault.registerPool(
            pool,
            tokenConfig,
            swapFeePercentage,
            getNewPoolPauseWindowEndTime(),
            false,
            roleAccounts,
            poolHooksContract,
            liquidityManagement
        );
    }

    // For tests; otherwise can't get the exact event arguments.
    function registerPoolAtTimestamp(
        address pool,
        TokenConfig[] memory tokenConfig,
        uint32 timestamp,
        PoolRoleAccounts memory roleAccounts,
        address poolHooksContract,
        LiquidityManagement calldata liquidityManagement
    ) external {
        _vault.registerPool(
            pool,
            tokenConfig,
            DEFAULT_SWAP_FEE,
            timestamp,
            false,
            roleAccounts,
            poolHooksContract,
            liquidityManagement
        );
    }

    function _getDefaultLiquidityManagement() private pure returns (LiquidityManagement memory) {
        LiquidityManagement memory liquidityManagement;
        liquidityManagement.enableAddLiquidityCustom = true;
        liquidityManagement.enableRemoveLiquidityCustom = true;
        return liquidityManagement;
    }
}
