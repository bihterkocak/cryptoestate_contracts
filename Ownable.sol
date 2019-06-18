pragma solidity ^0.4.24;



contract Ownable {

    address public owner;

   
    function Ownable() public {
        owner = msg.sender;
    }

  
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function getContractOwner() public  view returns(address) {
        return owner;
    }

   
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}