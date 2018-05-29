pragma solidity ^0.4.18;

import './DiscoverBlockchainCoin.sol';
import '../node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
import '../node_modules/zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';

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

    // Constructor
    // ============
    function DiscoverBlockchainCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap) CappedCrowdsale(_cap) FinalizableCrowdsale() RefundableCrowdsale(_goal) Crowdsale(_startTime, _endTime, _rate, _wallet) public {
        require(_goal <= _cap);
    }
    // =============

    // Token Deployment
    // =================
    function createTokenContract() internal returns (MintableToken) {
        return new DiscoverBlockchainCoin();
        // Deploys the ERC20 token. Automatically called when crowdsale contract is deployed
    }
    // ==================

    // Crowdsale Stage Management
    // =========================================================

    // Change Crowdsale Stage. Available Options: PrivatePreICO, PreICO, ICO
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

    // Change the current rate
    function setCurrentRate(uint256 _rate) private {
        rate = _rate;
    }

    // ================ Stage Management Over =====================

    // Token Purchase
    // =========================
    function() external payable {
        uint256 tokensThatWillBeMintedAfterPurchase = msg.value.mul(rate);

        if ((stage == CrowdsaleStage.PrivatePreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPrivatePreICO)) {
            msg.sender.transfer(msg.value);
            // Refund them
            EthRefunded("PrivatePreICO Limit Hit");
            return;
        }

        if ((stage == CrowdsaleStage.PreICO) && (token.totalSupply() + tokensThatWillBeMintedAfterPurchase > totalTokensForSaleDuringPreICO)) {
            msg.sender.transfer(msg.value);
            // Refund them
            EthRefunded("PreICO Limit Hit");
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

    function forwardFunds() internal {
        if (stage == CrowdsaleStage.PrivatePreICO || stage == CrowdsaleStage.PreICO) {
            wallet.transfer(msg.value);
            EthTransferred('Forwarding funds to wallet');
        } else if (stage == CrowdsaleStage.ICO) {
            EthTransferred('Forwarding funds to refundable vault');
            super.forwardFunds();
        }
    }
    // ===========================

    // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
    // ====================================================================

    function finish(address _ecosystemFund, address _bountyFund) public onlyOwner {
        require(!isFinalized);
        uint256 alreadyMinted = token.totalSupply();
        require(alreadyMinted < maxTokens);

        uint256 unsoldTokens = totalTokensForSale - alreadyMinted;
        if (unsoldTokens > 0) {
            tokensForEcosystem = tokensForEcosystem + unsoldTokens;
        }

        token.mint(_ecosystemFund, tokensForEcosystem);
        token.mint(_bountyFund, tokensForBounty);
        finalize();
    }
}
