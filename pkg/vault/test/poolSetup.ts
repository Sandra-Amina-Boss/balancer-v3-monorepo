import '@balancer-labs/v3-common/setupTests';

import { deploy } from '@balancer-labs/v3-helpers/src/contract';
import { MONTH } from '@balancer-labs/v3-helpers/src/time';
import { VaultMock } from '../typechain-types/contracts/test/VaultMock';
import { ERC20TestToken } from '@balancer-labs/v3-solidity-utils/typechain-types/contracts/test/ERC20TestToken';
import { BasicAuthorizerMock } from '@balancer-labs/v3-solidity-utils/typechain-types/contracts/test/BasicAuthorizerMock';
import { PoolMock } from '@balancer-labs/v3-pool-utils/typechain-types/contracts/test/PoolMock';

// This deploys a Vault, then creates 3 tokens and 2 pools. The first pool (A) is registered; the second (B) )s not,
// which, along with a registration flag in the Pool mock, permits separate testing of registration functions.
export async function setupEnvironment(factory: string): Promise<{
  vault: VaultMock;
  tokens: ERC20TestToken[];
  pools: PoolMock[];
}> {
  const PAUSE_WINDOW_DURATION = MONTH * 3;
  const BUFFER_PERIOD_DURATION = MONTH;

  const authorizer: BasicAuthorizerMock = await deploy('v3-solidity-utils/BasicAuthorizerMock');
  const vault: VaultMock = await deploy('VaultMock', {
    args: [authorizer.getAddress(), PAUSE_WINDOW_DURATION, BUFFER_PERIOD_DURATION],
  });
  const vaultAddress = await vault.getAddress();

  const tokenA: ERC20TestToken = await deploy('v3-solidity-utils/ERC20TestToken', { args: ['Token A', 'TKNA', 18] });
  const tokenB: ERC20TestToken = await deploy('v3-solidity-utils/ERC20TestToken', { args: ['Token B', 'TKNB', 6] });
  const tokenC: ERC20TestToken = await deploy('v3-solidity-utils/ERC20TestToken', { args: ['Token C', 'TKNC', 8] });

  const tokenAAddress = await tokenA.getAddress();
  const tokenBAddress = await tokenB.getAddress();
  const tokenCAddress = await tokenC.getAddress();

  const poolATokens = [tokenAAddress, tokenBAddress, tokenCAddress];
  const poolBTokens = [tokenAAddress, tokenCAddress];

  const poolA: PoolMock = await deploy('v3-pool-utils/PoolMock', {
    args: [vaultAddress, 'Pool A', 'POOLA', factory, poolATokens, true],
  });
  const poolB: PoolMock = await deploy('v3-pool-utils/PoolMock', {
    args: [vaultAddress, 'Pool B', 'POOLB', factory, poolBTokens, false],
  });

  return { vault: vault, tokens: [tokenA, tokenB, tokenC], pools: [poolA, poolB] };
}