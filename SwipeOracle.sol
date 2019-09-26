pragma solidity ^0.5.0;

import "./SwipeToken.sol";

// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Ownable {

    address owner;
    address admin;

    event OwnershipTransferred(address indexed _from, address indexed _to);


    constructor() public {
        owner = msg.sender;
        admin = address(0);
    }

    modifier onlyAdmin {
        require(msg.sender == owner || msg.sender == admin);

        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner || msg.sender == admin);

        _;
    }

    function viewOwner() public view returns(address) {
        return owner;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }

    function viewAdmin() public view returns(address) {
        return admin;
    }

    function setAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

}



contract SwipeOracle is Ownable {
    using SafeMath for uint;

    uint networkFee = 80;
    uint oracleFee = 20;
    uint activationFee = 1000000000000000000;
    
    constructor() public {
    }


    function viewNetworkFee() public view returns(uint) {
        return networkFee;
    }

    function setNetworkFee(uint fee) public onlyAdmin {
        networkFee = fee;
    }

    function viewOracleFee() public view returns(uint) {
        return oracleFee;
    }

    function setOracleFee(uint fee) public onlyAdmin {
        oracleFee = fee;
    }

    function viewActivationFee() public view returns(uint) {
        return activationFee;
    }

    function setActivationFee(uint fee) public onlyAdmin {
        activationFee = fee;
    }
}
