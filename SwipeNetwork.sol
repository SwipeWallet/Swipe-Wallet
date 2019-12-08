pragma solidity ^0.5.0;

import "./SwipeToken.sol";

// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Ownable {

    address owner;
    address admin;

    event OwnershipTransferred(address indexed _from, address indexed _to);


    // ----------------------------------------------------------------------------

    // Constructor

    // ----------------------------------------------------------------------------
    constructor() public {
        owner = msg.sender;
        admin = address(0);
    }

    modifier onlyAdmin {
        require(msg.sender == owner || msg.sender == admin);

        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);

        _;
    }


    // ----------------------------------------------------------------------------

    // Get Owner Address

    // ----------------------------------------------------------------------------
    function viewOwner() external view returns(address) {
        return owner;
    }


    // ----------------------------------------------------------------------------

    // Set Owner

    // ----------------------------------------------------------------------------
    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }


    // ----------------------------------------------------------------------------

    // Get Admin Address

    // ----------------------------------------------------------------------------
    function viewAdmin() external view returns(address) {
        return admin;
    }


    // ----------------------------------------------------------------------------

    // Set Admin

    // ----------------------------------------------------------------------------
    function setAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin;
    }

}



contract SwipeNetwork is Ownable {
    using SafeMath for uint;

    SwipeToken public token;

    uint transferFee = 1000000000000000000;
    uint networkFee = 80;
    uint oracleFee = 20;
    uint activationFee = 1000000000000000000;
    uint protocolRate = 100;

    // ----------------------------------------------------------------------------

    // Constructor

    // ----------------------------------------------------------------------------
    constructor(address payable _token) public {
        token = SwipeToken(_token);
    }

    // ----------------------------------------------------------------------------

    // Get Transfer Fee

    // ----------------------------------------------------------------------------
    function viewTrsansferFee() external view returns(uint) {
        return transferFee;
    }


    // ----------------------------------------------------------------------------

    // Set Transfer Fee

    // ----------------------------------------------------------------------------
    function setTransferFee(uint fee) external onlyAdmin {
        transferFee = fee;
    }

    // ----------------------------------------------------------------------------

    // Get Network Fee

    // ----------------------------------------------------------------------------
    function viewNetworkFee() external view returns(uint) {
        return networkFee;
    }


    // ----------------------------------------------------------------------------

    // Set Network Fee

    // ----------------------------------------------------------------------------
    function setNetworkFee(uint fee) external onlyAdmin {
        networkFee = fee;
    }


    // ----------------------------------------------------------------------------

    // Get Oracle Fee

    // ----------------------------------------------------------------------------
    function viewOracleFee() external view returns(uint) {
        return oracleFee;
    }


    // ----------------------------------------------------------------------------

    // Set Oracle Fee

    // ----------------------------------------------------------------------------
    function setOracleFee(uint fee) external onlyAdmin {
        oracleFee = fee;
    }


    // ----------------------------------------------------------------------------

    // Get Activation Fee

    // ----------------------------------------------------------------------------
    function viewActivationFee() external view returns(uint) {
        return activationFee;
    }


    // ----------------------------------------------------------------------------

    // Set Activation Fee

    // ----------------------------------------------------------------------------
    function setActivationFee(uint fee) external onlyAdmin {
        activationFee = fee;
    }

    function viewProtocolRate() external view returns(uint) {
        return protocolRate;
    }

    function setProtocolRate(uint rate) external onlyAdmin {
        protocolRate = rate;
    }

    function getBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    function buySXP(address to, uint amount) external onlyAdmin returns (bool success) {
        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }

    function buySXPMultiple(address[] memory to, uint[] memory amount) public onlyAdmin returns (bool success) {
        uint total = 0;
        for (uint i = 0; i < amount.length; i ++) {
            total = total.add(amount[i]);
        }

        require(getBalance() >= total, 'not enough reserve balance');

        for (uint j = 0; j < to.length; j ++) {
            require(to[j] != address(0), 'invalid address');
            if (!token.transfer(to[j], amount[j])) {
                return false;
            }
        }

        return true;
    }

    function rewardSXP(address to, uint amount) external onlyAdmin returns (bool success) {
        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }
    
    function secureDeposit(address to, uint amount) external onlyAdmin returns (bool success) {
        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }
}
