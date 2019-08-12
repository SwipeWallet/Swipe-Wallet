pragma solidity ^0.5.0;

import "./SwipeToken.sol";

contract RequestAllowance is Owned {
    using SafeMath for uint;
       
    SwipeToken token;
    address feeAdmin;
    mapping(address => bool) allowedUsers;
    mapping(address => uint) feeBalances;
    event Approval(address indexed tokenOwner);

    /// Create a new RequestAllowance
    constructor(address payable addrToken, address _feeAdmin) public {
        token = SwipeToken(addrToken);
        feeAdmin = _feeAdmin;
    }
    
    function setFeeAdmin(address _feeAdmin) public onlyOwner {
        feeAdmin = _feeAdmin;
    }

    function allowedOf(address user) public view returns(bool) {
        return allowedUsers[user];    
    }

    function feeBalanceOf(address user) public view returns(uint) {
        return feeBalances[user];    
    }

    // To get success, user need to approve 1 token to smart contract
    function requestAllowance() public returns (bool success) {
        require(allowedUsers[msg.sender] == false, 'user is already allowed');
        require(token.balanceOf(msg.sender) >= 1, 'user balance is not sufficient');
        require(token.allowance(msg.sender, address(this)) >= 1, 'token is not allowd to smart contract');
        
        if (token.transferFrom(msg.sender, address(this), 1)) {
            allowedUsers[msg.sender] = true;
            emit Approval(msg.sender);
            return true;
        }
        
        return false;
    }

    // To get success, user need to approve tokens to smart contract
    function depositForFee(uint tokenAmount) public returns (bool success) {
        require(allowedUsers[msg.sender] == true, 'user is not allowed');
        require(token.balanceOf(msg.sender) >= tokenAmount, 'user balance is not sufficient');
        require(token.allowance(msg.sender, address(this)) >= tokenAmount, 'tokens are not allowd to smart contract');
        
        if (token.transferFrom(msg.sender, address(this), tokenAmount)) {
            feeBalances[msg.sender] = feeBalances[msg.sender].add(tokenAmount);
            return true;
        }
        
        return false;
    }
    
    function payFee(uint tokenAmount) public returns (bool success) {
        require(allowedUsers[msg.sender] == true, 'user is not allowed');
        require(feeBalances[msg.sender] >= tokenAmount, 'not enough fee balance');
        
        uint burnAmount = tokenAmount.mul(8).div(10);
        uint fee = tokenAmount - burnAmount;
        if (token.burn(burnAmount)) {
            token.transfer(feeAdmin, fee);
            feeBalances[msg.sender] = feeBalances[msg.sender].sub(tokenAmount);
            return true;
        }
        
        return false;
    }
    
    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () external payable {

        revert();

    }
}
