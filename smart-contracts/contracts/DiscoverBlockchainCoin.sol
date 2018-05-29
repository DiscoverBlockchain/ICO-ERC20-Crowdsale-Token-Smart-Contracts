pragma solidity ^0.4.18;

import '../node_modules/zeppelin-solidity/contracts/token/MintableToken.sol';

/**
 * @title DiscoverBlockchainCoin
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract DiscoverBlockchainCoin is MintableToken {
    string public constant name = 'DiscoverBlockchain Coin';
    string public constant symbol = 'DSC';
    uint8 public constant decimals = 18;
}
