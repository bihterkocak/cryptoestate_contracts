pragma solidity ^0.4.24;

import "./PlotAccessControl.sol";
import "./BoundsCheck.sol";
import "./Ownable.sol";
import "./ERC721.sol";



contract PlotBase is  PlotAccessControl, ERC721,  Ownable, BoundsCheck {


    event Transfer(address from, address to, uint256 uintPlotBoundsKey);
    event BuyPlotFromCryptoEstateEvent(address indexedBuyer, bytes16 plotBoundsKey);
    event PutOnSaleEvent( bytes16 _plotBoundsKey, uint256 _plotSalePrice,address owner);
    event RemoveOnSaleEvent( bytes16 _plotBoundsKey,address owner);
    event BuyPlotFromAnotherEvent(address indexedBuyer, address indexedSeller, bytes16 plotBoundsKey, uint256 price);
    event CreatePlotEvent(uint256 newPlotListIndex, address hasPlotOwner);
    event TransferPromotionPlotEvent(bytes16 plotBoundsKey, address newOwner);


    struct Plot {
    
        uint64 creationDate; 
        uint64 operationDate;
        bytes16 plotBoundsKey;
        uint initialPlotPrice;
        uint lastSalePrice;
        bool isInSale;
        uint salePrice;
        uint16 countryCode;
    }

    Plot[] internal plotList;

    uint256 internal promotionPlotMaxIndex;
    bool[]  internal promotionPlotListTransfer;

    mapping (uint256 => address) internal plotListIndexToOwner;
    mapping (bytes16 => address)  plotBoundsKeyToOwner; 


    mapping (uint256 => uint256) internal boundsKeyUintToPlotListIndex;
    mapping (address => uint256) internal ownershipTokenCount; 
    mapping (uint256 => uint256) internal plotListIndexToBoundsKeyUint;

    uint private plotInitialPrice = 130 finney; 
    function getPlotInitialPrice() public view returns(uint){
        return plotInitialPrice + monthsFromContractCreation() * (54 szabo * 30);


    }
    function getMinimumSalePrice() public view returns(uint){
     return plotInitialPrice;   
    }

    function daysFromContractCreation() public view returns(uint64) {
      uint64 daysFromContractCreationValue = (uint64(now) - contractCreationDate)/86400; //seconds in day 86400
      return daysFromContractCreationValue;
    }
     function monthsFromContractCreation() public view returns(uint64) {
      uint64 daysFromContractCreationValue = (uint64(now) - contractCreationDate)/(86400 * 30); //seconds in day 86400
      return daysFromContractCreationValue;
    }



    mapping (uint256 => address) internal forsalePlotPreviousOwnerList; 



    mapping (uint256 => address) internal plotBoundsKeyToApproved;
    
     BoundsCheck public boundsCheckInstance ;
  
 
  
     uint64 contractCreationDate;
    mapping (address => mapping (address => bool)) internal operatorApprovals;


          function PlotBase() public{
        
            contractCreationDate = uint64(now);

        }


    function _owns(address _claimant, uint256 _uintPlotBoundsKey) public view returns (bool) {
        uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(_uintPlotBoundsKey);
        return plotListIndexToOwner[plotListIndex] == _claimant;
    }

    function _ownsBytes16(address _claimant, bytes16 _plotBoundsKey) public view returns (bool) {
        uint256 _uintPlotBoundsKey = uint256(_plotBoundsKey);
        return _owns(_claimant, _uintPlotBoundsKey);
    }

    function getPlotOwner(uint _uintPlotBoundsKey) public view  returns(address) {
        uint plotListIndex = uintPlotBoundsKeyToPlotListIndex(_uintPlotBoundsKey);
        require(plotListIndex >= 0  && plotListIndex < plotList.length);
        address a = plotListIndexToOwner[plotListIndex];
        require(a != address(0));
        return a;
    }
    function getPlotOwnerWithIndex(uint plotListIndex) public view returns(address) {

        require(plotListIndex >= 0  && plotListIndex < plotList.length);
        address a = plotListIndexToOwner[plotListIndex];
        require(a != address(0));
        return a;
    }
    

    function getPlotOwnerBytes16(bytes16 _PlotBoundsKey) view public  returns(address) {
        uint key = uint(_PlotBoundsKey);
        return getPlotOwner(key);
    }
    

    function uintPlotBoundsKeyToPlotListIndex(uint256 _uintPlotBoundsKey) view public  returns(uint256) {
       
        uint256 plotlistIndex = boundsKeyUintToPlotListIndex[_uintPlotBoundsKey];
        return plotlistIndex;
    }

    function _transfer(address _from, address _to, uint256 _uintPlotBoundsKey) internal {
        require(plotListIndex >= 0 && plotListIndex < plotList.length); 
        require(_to != address(0x0));
        require(_to != _from);
        uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(_uintPlotBoundsKey);
  
      
         ownershipTokenCount[_to] = ownershipTokenCount[_to] + 1;
        plotListIndexToOwner[plotListIndex] = _to;
      
        if (_from != address(0)) {
           ownershipTokenCount[_from] = ownershipTokenCount[_from]-1;
        }
        bytes16 plotBoundsKey = bytes16(_uintPlotBoundsKey);
        plotBoundsKeyToOwner[plotBoundsKey] = _to;
        emit Transfer(_from, _to, _uintPlotBoundsKey);
    }



    function getPlotBoundsKeyToOwner(bytes16 _plotBoundsKey) public view  returns(address) {
        address plotOwner = plotBoundsKeyToOwner[_plotBoundsKey];
        return plotOwner;
    }

    function _createPlot(bytes16 _plotBoundsKey, uint16 countryCode, address _owner) internal returns (uint) {
        uint256 uintPlotBoundsKey = uint256(_plotBoundsKey);
       
        address hasPlotOwner = getPlotBoundsKeyToOwner(_plotBoundsKey);
        require(hasPlotOwner == 0x0); 
        require(countryCode > 0 && countryCode < 999);
        require(checkCorrectness(_plotBoundsKey));   

        Plot memory _plot = Plot({

            creationDate: uint64(now),
            operationDate: uint64(now),
            plotBoundsKey:_plotBoundsKey,
            initialPlotPrice:getPlotInitialPrice(),
            lastSalePrice:getPlotInitialPrice(),
            isInSale:false,
            salePrice:0,
            countryCode:countryCode

        });

        uint256 newPlotListIndex = plotList.push(_plot)-1;
        boundsKeyUintToPlotListIndex[uintPlotBoundsKey] = newPlotListIndex;
        plotListIndexToBoundsKeyUint[newPlotListIndex] = uintPlotBoundsKey;
       
        require(newPlotListIndex == uint256(uint32(newPlotListIndex))); 

       
        emit CreatePlotEvent(newPlotListIndex, _owner);

        _transfer(0x0, _owner, uintPlotBoundsKey);
        
        return newPlotListIndex;
    }

}

