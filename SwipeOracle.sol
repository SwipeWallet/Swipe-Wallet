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
    function setAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

}



contract SwipeOracle is Ownable {
    using SafeMath for uint;

    uint networkFee = 80;
    uint oracleFee = 20;
    uint activationFee = 1000000000000000000;


    // ----------------------------------------------------------------------------

    // Constructor

    // ----------------------------------------------------------------------------
    constructor() public {
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
}
