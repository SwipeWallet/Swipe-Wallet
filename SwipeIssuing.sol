/**
 *Submitted for verification at Etherscan.io on 2019-08-16
*/

pragma solidity ^0.5.0;

import "SwipeToken.sol";

/** 
 * @title SwipeIssuing
 * @company Swipe Wallet LTD 
 * @URL https://www.swipe.io
 */
contract SwipeIssuing is Owned {
    using SafeMath for uint;
        
    struct PartnerInfo {
        bool activated;
        uint index;
        uint fee;
    }
  
    mapping(address => PartnerInfo) private partner_info;
    address[] private partners;
    
    uint lockEligibleAmount = 300000 * 10**uint(18); //300k SXP
    SwipeToken private sxpToken;

    /** 
     * @dev Create a new PartnerContract
     * @param _sxpToken address of SwipeToken
     */
    constructor(address payable _sxpToken) public {
        sxpToken = SwipeToken(_sxpToken);
    }
    
    function isRegistered(address partner) 
    public view 
    returns(bool) 
    {
        if(partners.length == 0) return false;
        return (partners[partner_info[partner].index] == partner);
    }

    function isActivated(address partner) 
    public view 
    returns(bool) 
    {
        if (!isRegistered(partner)) return false;
        return partner_info[partner].activated;
    }
  
    /** 
     * @dev Add new partner in contract partners array
     * @param partner address of new partner
     */
    function registerPartner(address partner) external onlyOwner {
        require(partner != address(0), "invalid partner address");
        require(isRegistered(partner) == false, "Already registered!");
        partner_info[partner].activated = false;
        partner_info[partner].index     = partners.push(partner)-1;
        partner_info[partner].fee = 0;
    }
    

    /** 
     * @dev Remove partner from contract partners array
     * @param partner address of partner
     */
    function delistPartner(address partner) external onlyOwner {
        require(partner != address(0), "invalid partner address");
        require(isRegistered(partner) == true, "Not registered!");
        
        uint rowToDelete = partner_info[partner].index;
        address keyToMove = partners[partners.length-1];
        partners[rowToDelete] = keyToMove;
        partner_info[keyToMove].index = rowToDelete; 
        partners.length--;
    }
    
    /** 
     * @dev if partner has more than 300k SXP, 300k SXP will be locked and activate partner
     * @param partner address of partner
     */
    function activatePartner(address partner) external onlyOwner {
        require(isRegistered(partner) == true, "Not registered!");
        require(isActivated(partner) == false, "Already activated!");
        require(sxpToken.balanceOf(partner) >= lockEligibleAmount, "Insufficient balance!");
        if (sxpToken.transferFrom(partner, address(this), lockEligibleAmount)) {
            partner_info[partner].activated = true;
        }
    }

    /** 
     * @dev unlock 300k SXP, and deactivate partner
     * @param partner address of partner
     */
    function deactivatePartner(address partner) external onlyOwner {
        require(isRegistered(partner) == true, "Not registered!");
        require(isActivated(partner) == true, "Not activated!");
        if (sxpToken.transfer(partner, lockEligibleAmount)) {
            partner_info[partner].activated = false;
        }
    }

    /** 
     * @dev add SXP to partner as amount param
     * @param amount amount to add
     */
    function loadFees(address partner, uint amount) external onlyOwner {
        require(isRegistered(partner) == true, "Not registered!");
        require(isActivated(partner) == true, "Not activated!");
        require(sxpToken.balanceOf(partner) >= amount, "Insufficient balance!");
        if (sxpToken.transferFrom(partner, address(this), amount)) {
            partner_info[partner].fee = partner_info[partner].fee.add(amount);
        }
    }
    
    /** 
     * @dev  burn 50% of amount param and move 50% of amount param to owner from partner's loadFees
     * @param partner address of partner
     * @param amount amount to process
     */
    function processFees(address partner, uint amount) external onlyOwner{
        require(isRegistered(partner) == true, "Not registered!");
        require(isActivated(partner) == true, "Not activated!");
        require(partner_info[partner].fee >= amount, "Insufficient fee loaded!");
        if (sxpToken.burn(amount.div(2))) {
            if (sxpToken.transfer(owner, amount.div(2))) {
                partner_info[partner].fee = partner_info[partner].fee.sub(amount);
            }
        }
    }
    
    /** 
     * @dev  get number of activated partners 
     */
    function viewPartners()
    public view 
    returns(address[] memory) 
    {
        uint count = 0;
        for (uint i = 0; i < partners.length; i ++) {
            if (partner_info[partners[i]].activated) {
                count ++;
            }
        }
        
        address[] memory ret = new address[](count);
        uint index = 0;
        for (uint i = 0; i < partners.length; i ++) {
            if (partner_info[partners[i]].activated) {
                ret[index] = partners[i];
                index ++;
            }
        }
    }
 }

