pragma solidity ^0.5.0;

import "./SwipeToken.sol";

contract RequestAllowance is Owned {
    SwipeToken token;
    uint fee = 20;
    mapping(address => bool) allowedUsers;
    event Approval(address indexed tokenOwner);

    // Create a new RequestAllowance
    constructor(address payable addrToken, uint _fee) public {
        token = SwipeToken(addrToken);
        fee = _fee;
    }

    function allowedOf(address user) public view returns(bool) {
        return allowedUsers[user];    
    }
    
    function requestAllowance() public {
        require(allowedUsers[msg.sender] == false, 'user is already allowed');
        require(token.balanceOf(msg.sender) >= fee, 'user balance is not sufficient');
        
        if (token.burnForAllowance(msg.sender, owner, fee)) {
            allowedUsers[msg.sender] = true;
            emit Approval(msg.sender);
        }
    }
    
    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () external payable {

        revert();

    }
}
