pragma solidity ^0.4.23;

import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/**
 * @title DiscoverBlockchainToken
 * @dev DiscoverBlockchainToken is ERC20 Ownable, BurnableToken & StandardToken
 * It is meant to be used in a DiscoverBlockchain Crowdsale contract
 */
contract DiscoverBlockchainToken is Ownable, BurnableToken, StandardToken {
    string public constant name = 'DiscoverBlockchain Token';
    string public constant symbol = 'DSC';
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 500000000 * (10 ** uint256(decimals));

    constructor() public {
        totalSupply_ = TOTAL_SUPPLY;
        balances[owner] = TOTAL_SUPPLY;

        emit Transfer(address(0), owner, totalSupply_);
    }
}
