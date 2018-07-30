pragma solidity ^0.4.24;

import './DiscoverBlockchainToken.sol';
import '../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol';

/**
 * @title DiscoverBlockchainCrowdsale
 * @author Yosra Helal 
 * @dev DiscoverBlockchainCrowdsale is Crowdsale Smart Contract with a limit for total contributions, funding goal, and
 * the possibility of users getting a refund if goal is not met.
 */
contract DiscoverBlockchainCrowdsale is Pausable {
    // ICO Stage
    enum CrowdsaleStage {PrivatePreICO, PreICO, ICO}
    CrowdsaleStage public stage = CrowdsaleStage.PrivatePreICO; // By default it's Private Pre Sale

    // Token Distribution
    DiscoverBlockchainToken token;
    address public wallet; // wallet to save raised ether
    uint256 public maxTokens = 500000000000000000000000000; // There will be total 500 000 000 DiscoverBlockchain tokens
    uint256 public tokensForEcosystem = 100000000000000000000000000; // 100 000 000 DSC tokens are reserved for Ecosystem - Platform
    uint256 public tokensForBounty = 40000000000000000000000000; // 40 000 000 tokens are reserved for Bounties, Rewards & Bonuses
    uint256 public totalTokensForSale = 360000000000000000000000000; // 360 000 000 DSC tokens will be sold in Crowdsale
    uint256 public totalTokensForSaleDuringPrivatePreICO = 60000000000000000000000000; // 60 000 000 DSC tokens will be sold during Private PreICO
    uint256 public totalTokensForSaleDuringPreICO = 120000000000000000000000000; // 120 000 000 DSC tokens will be sold during Private PreICO
    // Dates
    // PrivatePreICO period
    uint256 public startingDatePrivatePreICO = 1538352000; // epoch timestamp for the starting date PrivatePreICO period Human time (GMT): Monday, October 1, 2018 12:00:00 AM
    uint256 public endDatePrivatePreICO = 1540944000; // timestamp for the ending date PrivatePreICO period Human time (GMT): Wednesday, October 31, 2018 12:00:00 AM

    uint256 public softCapPrivatePreICO = 10000 ether;
    // PreICO period
    uint256 public startingDatePreICO = 1541030400; // timestamp for the starting date PreICO period Human time (GMT): Thursday, November 1, 2018 12:00:00 AM
    uint256 public endDatePreICO = 1543536000; // timestamp for the ending date PreICO period Human time (GMT): Friday, November 30, 2018 12:00:00 AM
    // ICO period
    uint256 public startingDateICO = 1543622400; // timestamp for the starting date ICO period Human time (GMT): Saturday, December 1, 2018 12:00:00 AM

    // Amount raised in Private PreICO and PreICO
    uint256 public totalWeiRaisedDuringPrivatePreICO;
    uint256 public totalWeiRaisedDuringPreICO;
    uint256 public totalWeiRaised;
    uint256 public hardCap = 60000 ether;

    // Mapping contributions during the private PreICO
    mapping (address => uint256) contributions;
    mapping (uint => address) public contributorPositions;
    uint256 contributorsCount;

    // Events
    event EthTransferred(uint256 _value, address _from, address _to);
    event EthRefunded(uint256 _value, address _from, address _to);

    /**
     * @dev DiscoverBlockchainCrowdsale constructor
     * Creates DiscoverBlockchainCrowdsale Smart Contracts
     * Checks if the goal is less then hard cap and transfers tokens for bounty to bountyFund
     */
    constructor(ERC20 _token, uint256 _rate, address _wallet, address _bountyFund, address _ecosystemFund) public {
        require(_goal <= _cap);
        wallet = _wallet;
        token = DiscoverBlockchainToken(_token);
        token.transfer(_bountyFund, tokensForBounty); // to validate
        token.transfer(_ecosystemFund, tokensForEcosystem); // to validate
    }

    /**
     * @dev Token Purchase
     */
    function() external payable {
        uint256 tokensToTransfer = msg.value.mul(rate);
        require(totalWeiRaised.add(msg.value) <= hardCap));
        if (stage == CrowdsaleStage.PrivatePreICO) {
          require(_value <= totalTokensForSaleDuringPrivatePreICO);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaisedDuringPrivatePreICO = totalWeiRaisedDuringPrivatePreICO.add(msg.value);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          contributions[msg.sender] = contributions[msg.sender].add(msg.value);
          contributorPositions[contributorsCount] = msg.sender;
          contributorsCount++;
          return;
        }
        else if (stage == CrowdsaleStage.PreICO) {
          require(_value <= totalTokensForSaleDuringPreICO);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          return;
        }
        else {
          require(_value <= totalTokensForSale);
          token.transfer(msg.sender, tokensToTransfer);
          totalWeiRaised = totalWeiRaised.add(msg.value);
          return;
        }
    }

    /**
     * @dev Change Crowdsale Stage
     * Available Options: PrivatePreICO, PreICO, ICO
     */
    function setCrowdsaleStage(uint value) public onlyOwner {
        require(value == CrowdsaleStage.PrivatePreICO || value == CrowdsaleStage.ICO);
        if (uint(CrowdsaleStage.PrivatePreICO) == value) {
            stage = CrowdsaleStage.PrivatePreICO;
            // Set price of DSC tokens per 1 ETH for each the PrivatePreICO
            setCurrentRate(10000);
        } else{
            stage = CrowdsaleStage.ICO;
            // Set price of DSC tokens per 1 ETH for each the ICO
            setCurrentRate(5000);
        }
    }
    /*
    * @dev Change the current rate by the owner,
    * if the ETH prices change a lot during our Crowdsale
    */
    function setCurrentRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    /**
     * @dev Change the current rate
     */
    function setCurrentRate(uint256 _rate) internal {
        rate = _rate;
    }

    /**
    * @dev Refund all the contributors in the private PreICO
    */
    function _refund() internal {
      for(uint i = 0; i < contributorsCount; i++){
        address contributor = contributorPositions[i];
        uint256 amountRefunded = contributions[contributor];
        require(contributor.transfer(amountRefunded));
        emit EthRefunded(address(this).balance, address(this), contributor);
      }
    }
    /**
     * @dev Finalize Crowdsale
     */
    function finish() public onlyOwner {
        require(totalWeiRaised >= hardCap);
        // transfer the raised ether
        wallet.transfer(address(this).balance);
        emit EthTransferred(address(this).balance, address(this), wallet);
    }

    /**
    * @dev Close the private ico period and switch to the pre sale period
    */
    function finishPrivatePreICO() public onlyOwner {
        require (now >= endDatePrivatePreICO);
        // check if the soft cap of the private PreICO period is reached
        if(totalWeiRaisedDuringPrivatePreICO >= softCapPrivatePreICO){
          // transfer the raised ether
          wallet.transfer(address(this).balance);
          emit EthTransferred(address(this).balance, address(this), wallet);
          // switch the next stage : PreICO period
          stage = CrowdsaleStage.PreICO;
          setCurrentRate(6667);
        }
      else{
         // refund all the funds
         _refund();
      }
    }
}
