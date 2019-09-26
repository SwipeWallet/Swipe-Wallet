pragma solidity ^0.5.0;

import "./SwipeOracle.sol";

contract StateLock is Owned {
     using SafeMath for uint;

    struct stateLockData {
        uint id;
        uint amount;
        uint releaseTime;
    }
    
    stateLockData[] lockData;
    uint constant error = 2**256 - 1;

    constructor() public {
        
    }
    
    function viewLocked() public view returns(uint count, uint[] memory ids, uint[] memory amounts, uint[] memory expireTimes) {
        count = lockData.length;
        ids = new uint[](count);
        amounts = new uint[](count);
        expireTimes = new uint[](count);

        for (uint i = 0; i < lockData.length; i ++) {
            ids[i] = lockData[i].id;
            amounts[i] = lockData[i].amount;
            expireTimes[i] = lockData[i].releaseTime;
        }
    }

    function getLockedAmount() public view returns(uint amount) {
        amount = 0;
        for (uint i = 0; i < lockData.length; i ++) {
            amount = amount.add(lockData[i].amount);
        }
        
        return amount;
    }

    function findLockState(uint _id) private view returns(uint) {
        for (uint i = 0; i < lockData.length; i ++) {
            if (lockData[i].id == _id) {
                return i;
            }
        }
        
        return error;
    }
    
    function removeByIndex(uint i) private {
        if (i < lockData.length) {
            lockData[i] = lockData[lockData.length-1];
            lockData.length--;
        }
    }
    
    function cardLock(uint _id, uint _amount, uint _lockTime) public onlyOwner {
        require(findLockState(_id) == error, 'already locked');
        lockData.push(stateLockData(_id, _amount, now.add(_lockTime)));
    }
    
    function cardUnlock(uint _id) public onlyOwner{
        uint index = findLockState(_id);
        require(index != error, 'cannot find lock');
        require(lockData[index].releaseTime <= now, 'not passed lock time');
        
        removeByIndex(index);
    }
}

contract WalletContract is StateLock {
    using SafeMath for uint;

    SwipeToken public token;
    SwipeOracle public swipeOracle;
    
    bool public activated = false;
    uint lockedSXP = 0;
    
    event Activate(address indexed tokenOwner);
    
    constructor(address payable _token, address oracle) public {
        token = SwipeToken(_token);
        swipeOracle = SwipeOracle(oracle);
    }
    
    function setOracle(address oracle) public onlyOwner {
        swipeOracle = SwipeOracle(oracle);
    }
    
    function activateSXP() public onlyOwner {
        uint activationFee = swipeOracle.viewActivationFee();
        require(getBalance() >= activationFee, 'not enough balance');
        
        activated = true;
        
        lockedSXP = activationFee;
        
        emit Activate(address(this));
    }
    
    function deactivateSXP() public onlyOwner returns (bool success) {
        require(activated == true, 'user is not activated');
        require(lockedSXP > 0, 'there is no activation fee');

        if (token.transfer(owner, lockedSXP)) {
            lockedSXP = 0;
            return true;
        }
        
        return false;
    }
    
    function getBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }
    
    function networkFee() public view returns(uint) {
        return swipeOracle.viewNetworkFee();
    }
    
    function transferSXP(address to, uint tokenAmount) public onlyOwner returns (bool success) {
        require(activated == true, 'user is not activated');
        require(getBalance() >= tokenAmount.add(lockedSXP).add(getLockedAmount()), 'not enough balance');
        
        if (token.transfer(to, tokenAmount)) {
            return true;
        }
        
        return false;
    }
    
    function transactionSXP(uint tokenAmount) public onlyOwner returns (bool success) {
        require(activated == true, 'user is not activated');
        require(getBalance() >= tokenAmount.add(lockedSXP).add(getLockedAmount()), 'not enough balance');
        
        uint netFee = swipeOracle.viewNetworkFee();
        uint oracleFee = swipeOracle.viewOracleFee();
        uint burnAmount = tokenAmount.mul(netFee).div(100);
        uint fee = tokenAmount.mul(oracleFee).div(100);
        if (token.burn(burnAmount)) {
            token.transfer(owner, fee);
            return true;
        }
        
        return false;
    }
}
