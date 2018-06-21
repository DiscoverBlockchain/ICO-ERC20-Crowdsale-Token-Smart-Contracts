pragma solidity ^0.4.23;

import '../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/**
 * @title DiscoverBlockchainToken
 * @author Aleksandar Djordjevic
 * @dev DiscoverBlockchainToken is ERC20 Ownable, BurnableToken & StandardToken
 * It is meant to be used in a DiscoverBlockchain Crowdsale contract
 */
contract DiscoverBlockchainToken is Ownable, BurnableToken, StandardToken {
    string public constant name = 'DiscoverBlockchain Token'; // DSC name
    string public constant symbol = 'DSC'; // DSC symbol
    uint8 public constant decimals = 18; // DSC decimal number
    uint256 public constant TOTAL_SUPPLY = 500000000 * (10 ** uint256(decimals)); // total amount of all DSC tokens - 500 000 000 DSC

    /**
     * @dev DiscoverBlockchainToken constructor, sets total supply and assigns total supply to owner
     */
    constructor() public {
        totalSupply_ = TOTAL_SUPPLY; // set total amount of tokens
        balances[owner] = TOTAL_SUPPLY; // transfer all tokens to smart contract owner

        emit Transfer(address(0), owner, totalSupply_); // emit Transfer event and notify that transfer of tokens was made
    }
}
