pragma solidity ^0.4.24;
contract PlotAccessControl {
  

    event ContractUpgrade(address newContract);
    event Pause();
    event Unpause();

    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    bool public paused = false;

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(msg.sender == cooAddress || msg.sender == ceoAddress || msg.sender == cfoAddress);
        _;
    }

   
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

 
    function setCFO(address _newCFO) external onlyCEO {
         
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }


    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

   
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

 
    modifier whenPaused {
        require(paused);
        _;
    }

    

    function pause() external onlyCLevel whenNotPaused  returns (bool){
        paused = true;
        emit Pause();
         return true;
    }


    function unpause() public onlyCEO whenPaused  returns (bool) {
      
        paused = false;
        emit Unpause();
        return true;
    }
    function isPaused() public view  returns(bool) {
        return paused;
    }
   
    function getCEO() public  view returns(address) {
        return ceoAddress;
    }
    function getCFO() public  view returns(address) {
        return cfoAddress;
    }
    function getCOO() public  view returns(address) {
        return cooAddress;
    }
 
 

}




