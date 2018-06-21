pragma solidity ^0.4.23;

import './DiscoverBlockchainToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol';
import '../node_modules/openzeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol';
import '../node_modules/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';

/**
 * @title DiscoverBlockchainCrowdsale
 * @author Aleksandar Djordjevic
 * @dev DiscoverBlockchainCrowdsale is Crowdsale Smart Contract with a limit for total contributions, funding goal, and
 * the possibility of users getting a refund if goal is not met.
 */
contract DiscoverBlockchainCrowdsale is CappedCrowdsale, RefundableCrowdsale {
    // ICO Stage
    // ============
    enum CrowdsaleStage {PrivatePreICO, PreICO, ICO}
    CrowdsaleStage public stage = CrowdsaleStage.PrivatePreICO; // By default it's Private Pre Sale
    // =============

    // Token Distribution
    // =============================
    uint256 public maxTokens = 500000000000000000000000000; // There will be total 500 000 000 DiscoverBlockchain tokens
    uint256 public tokensForEcosystem = 100000000000000000000000000; // 100 000 000 DSC tokens are reserved for Ecosystem - Platform
    uint256 public tokensForBounty = 40000000000000000000000000; // 40 000 000 tokens are reserved for Bounties, Rewards & Bonuses
    uint256 public totalTokensForSale = 360000000000000000000000000; // 360 000 000 DSC tokens will be sold in Crowdsale
    uint256 public totalTokensForSaleDuringPrivatePreICO = 60000000000000000000000000; // 60 000 000 DSC tokens will be sold during Private PreICO
    uint256 public totalTokensForSaleDuringPreICO = 120000000000000000000000000; // 120 000 000 DSC tokens will be sold during Private PreICO
    // ==============================

    // Amount raised in Private PreICO and PreICO
    // ==================
    uint256 public totalWeiRaisedDuringPrivatePreICO;
    uint256 public totalWeiRaisedDuringPreICO;
    // ===================

    // Events
    event EthTransferred(string text);
    event EthRefunded(string text);

    /**
     * @dev DiscoverBlockchainCrowdsale constructor
     */
    constructor(ERC20 _token, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap) CappedCrowdsale(_cap) FinalizableCrowdsale() RefundableCrowdsale(_goal) Crowdsale(_rate, _wallet, _token) public {
        require(_goal <= _cap);
    }

    /**
     * @dev Token Deployment
     */
    function createTokenContract() internal returns (BurnableToken) {
        return new DiscoverBlockchainToken();
        // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
    }

    /**
     * @dev Change Crowdsale Stage
     * Available Options: PrivatePreICO, PreICO, ICO
     */
    function setCrowdsaleStage(uint value) public onlyOwner {
        CrowdsaleStage _stage;

        if (uint(CrowdsaleStage.PrivatePreICO) == value) {
            _stage = CrowdsaleStage.PrivatePreICO;
        } else if (uint(CrowdsaleStage.PreICO) == value) {
            _stage = CrowdsaleStage.PreICO;
        } else if (uint(CrowdsaleStage.ICO) == value) {
            _stage = CrowdsaleStage.ICO;
        }

        stage = _stage;


        // Set price of DSC tokens per 1 ETH for each crowdsale stage
        if (stage == CrowdsaleStage.PrivatePreICO) {
            setCurrentRate(10000);
        } else if (stage == CrowdsaleStage.PreICO) {
            setCurrentRate(6667);
        } else if (stage == CrowdsaleStage.ICO) {
            setCurrentRate(5000);
        }
    }

    /**
     * @dev Change the current rate
     */
    function setCurrentRate(uint256 _rate) private {
        rate = _rate;
    }

    /**
     * @dev Token Purchase
     */
    function() external payable {
        uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);

        if ((stage == CrowdsaleStage.PrivatePreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPrivatePreICO)) {
            msg.sender.transfer(msg.value);
            // Refund them
            emit EthRefunded("PrivatePreICO Limit Hit");
            return;
        }

        if ((stage == CrowdsaleStage.PreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPreICO)) {
            msg.sender.transfer(msg.value);
            // Refund them
            emit EthRefunded("PreICO Limit Hit");
            return;
        }

        buyTokens(msg.sender);

        if (stage == CrowdsaleStage.PrivatePreICO) {
            totalWeiRaisedDuringPrivatePreICO = totalWeiRaisedDuringPrivatePreICO.add(msg.value);
        }

        if (stage == CrowdsaleStage.PreICO) {
            totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(msg.value);
        }
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases
     */
    function forwardFunds() internal {
        if (stage == CrowdsaleStage.PrivatePreICO || stage == CrowdsaleStage.PreICO) {
            wallet.transfer(msg.value);
            emit EthTransferred('Forwarding funds to wallet');
        } else if (stage == CrowdsaleStage.ICO) {
            emit EthTransferred('Forwarding funds to refundable vault');
            super._forwardFunds();
        }
    }

    /**
     * @dev Transfer Extra Tokens as needed, before finalizing the Crowdsale
     */
    function finish(address _ecosystemFund, address _bountyFund) public onlyOwner {
        require(!isFinalized);
        uint256 alreadyMinted = token.totalSupply();
        require(alreadyMinted < maxTokens);

        uint256 unsoldTokens = totalTokensForSale - alreadyMinted;
        if (unsoldTokens > 0) {
            tokensForEcosystem = tokensForEcosystem + unsoldTokens;
        }

        token.transfer(_ecosystemFund, tokensForEcosystem);
        token.transfer(_bountyFund, tokensForBounty);
        finalize();
    }
}
