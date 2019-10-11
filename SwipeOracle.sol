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
    function viewOwner() public view returns(address) {
        return owner;
    }


    // ----------------------------------------------------------------------------

    // Set Owner

    // ----------------------------------------------------------------------------
    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }


    // ----------------------------------------------------------------------------

    // Get Admin Address

    // ----------------------------------------------------------------------------
    function viewAdmin() public view returns(address) {
        return admin;
    }


    // ----------------------------------------------------------------------------

    // Set Admin

    // ----------------------------------------------------------------------------
    function setAdmin(address newAdmin) public onlyOwner {
        admin = newAdmin;
    }

}



contract SwipeOracle is Ownable {
    using SafeMath for uint;

    SwipeToken public token;

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

    // Get Network Fee

    // ----------------------------------------------------------------------------
    function viewNetworkFee() public view returns(uint) {
        return networkFee;
    }


    // ----------------------------------------------------------------------------

    // Set Network Fee

    // ----------------------------------------------------------------------------
    function setNetworkFee(uint fee) public onlyAdmin {
        networkFee = fee;
    }


    // ----------------------------------------------------------------------------

    // Get Oracle Fee

    // ----------------------------------------------------------------------------
    function viewOracleFee() public view returns(uint) {
        return oracleFee;
    }


    // ----------------------------------------------------------------------------

    // Set Oracle Fee

    // ----------------------------------------------------------------------------
    function setOracleFee(uint fee) public onlyAdmin {
        oracleFee = fee;
    }


    // ----------------------------------------------------------------------------

    // Get Activation Fee

    // ----------------------------------------------------------------------------
    function viewActivationFee() public view returns(uint) {
        return activationFee;
    }


    // ----------------------------------------------------------------------------

    // Set Activation Fee

    // ----------------------------------------------------------------------------
    function setActivationFee(uint fee) public onlyAdmin {
        activationFee = fee;
    }

    function viewProtocolRate() public view returns(uint) {
        return protocolRate;
    }

    function setProtocolRate(uint rate) public onlyAdmin {
        protocolRate = rate;
    }

    function getBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    function buySXP(address to, uint amount) public onlyAdmin returns (bool success) {
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

    function rewardSXP(address to, uint amount) public onlyAdmin returns (bool success) {
        require(getBalance() >= amount, 'not enough reserve balance');

        if (token.transfer(to, amount)) {
            return true;
        }

        return false;
    }
}
