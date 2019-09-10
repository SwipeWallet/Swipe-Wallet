pragma solidity ^0.5.0;

import "./SwipeToken.sol";

// ----------------------------------------------------------------------------

// Swipe Tokens Time Lock Contract

// ----------------------------------------------------------------------------

contract SwipeTimeLock is Owned {
    using SafeMath for uint;
    SwipeToken token;
    uint tokenslocked;
    
    // Release 10M tokens time period
    uint[] unlockTimestamps = [
        1596240000,             // 08/01/2020
        1627776000,             // 08/01/2021 
        1659312000,             // 08/01/2022 
        1690848000,             // 08/01/2023 
        1722470400,             // 08/01/2024 
        1754006400              // 08/01/2025
    ];

    constructor(address payable addrToken) public {
        token = SwipeToken(addrToken);
    }
    
    function getLockCount() public view returns (uint) {
        uint lock = 60000000000000000000000000;
        for (uint i = 0; i < 6; i ++) {
            if (now < unlockTimestamps[i]) break;
            lock = lock.sub(10000000000000000000000000);
        }
        
        return lock;
    }
    
    function getLockedTokenAmount() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function withdraw() public onlyOwner returns (uint withdrawed) {
        uint tokenLocked = getLockedTokenAmount();
        uint lockCount = getLockCount();
        
        require(tokenLocked >= lockCount, 'no unlocked tokens');
        uint allowed = tokenLocked.sub(lockCount);
        
        if (token.transfer(msg.sender, allowed)) {
            return allowed;
        }
        
        return 0;
    }
    
        // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () external payable {

        revert();

    }



    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        require(tokenAddress != address(token), 'SXP token is not allowed');

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }
}
