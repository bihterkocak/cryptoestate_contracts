pragma solidity ^0.4.24;

import "./PlotOperation.sol";
import "./PlotAccumulation.sol";

/// @title CryptoEstate: Collectible, plots on the Ethereum blockchain.
/// @author Bolkansoft (https://www.bolkansoft.com)
/// @dev The main CryptoEstate contract, keeps track of plots so they don't wander around and get lost.
contract CryptoEstate is PlotAccumulation {




        // This is the main CryptoEstate contract.

        address public newContractAddress;

        function CryptoEstate() public{
          
            paused = false;

            // the creator of the contract is the initial CEO
            ceoAddress = msg.sender;

            //the creator of the contract is also the initial COO
            cooAddress = msg.sender;

           _createInitialPlot(0,uint64(now),0); 
          

        }
      

        function _createInitialPlot(uint plotBoundsKey,uint64 pCreationDate,uint16 countryCode) private  {
                   
                    _createInitialPlotWithOwner( plotBoundsKey, pCreationDate, countryCode,msg.sender);
        }
        
        function _createInitialPlotWithOwner(uint plotBoundsKey,uint64 pCreationDate,uint16 countryCode,address plotOwner) private  {

                promotionPlotListTransfer.push(false);
            bytes16 plotBoundsKeyBytes16 = bytes16(plotBoundsKey);
            Plot memory _plot = Plot({creationDate: pCreationDate,operationDate: uint64(now), plotBoundsKey:plotBoundsKeyBytes16,
            initialPlotPrice:0,lastSalePrice:0,isInSale:false,salePrice:0,countryCode:countryCode});

            uint256 newPlotListIndex = plotList.push(_plot)-1;
            promotionPlotMaxIndex = newPlotListIndex;
            uint256 uintPlotBoundsKey = uint256(plotBoundsKey);
            boundsKeyUintToPlotListIndex[uintPlotBoundsKey] = newPlotListIndex;
            plotListIndexToBoundsKeyUint[newPlotListIndex] = uintPlotBoundsKey;
            _transfer(address(0x0), plotOwner, uintPlotBoundsKey); 

        }

        
        function createPromotionPlot(bytes16 plotBoundsKeyAsByte,uint64 plotCreationDate,address plotOwner,uint16 countryCode)  public onlyOwner whenNotPaused {
            require(canAddPromotionPlot);
            uint plotBoundsKey = uint(plotBoundsKeyAsByte);
            _createInitialPlotWithOwner(plotBoundsKey, plotCreationDate, countryCode,plotOwner);

        }

          
        function createPromotionPlotList(bytes16[] plotBoundsKeyAsByte,uint64[] plotCreationDate,address[]  plotOwnerList,uint16[] countryCodeList,uint arrayLength)  public onlyOwner whenNotPaused {
           
            for(uint i=0 ; i<arrayLength ; i++) {
                       createPromotionPlot(plotBoundsKeyAsByte[i],plotCreationDate[i],plotOwnerList[i],countryCodeList[i]); 
             }

        }


        bool canAddPromotionPlot = true;
        function preventPromotionPlotCreation() public onlyOwner whenNotPaused{
            canAddPromotionPlot = false;          
        }

        function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
        }

        function() external payable {
            revert();
        }

        function getPlotWithPlotBoundsKey(bytes16 _plotBoundsKey)  external  view  returns (
     
            uint64 creationDate,       
            uint64 operationDate,
            uint256 plotBoundsKey,
            uint256 initialPlotPrice,
            uint lastSalePrice,
            bool isInSale,
            uint256 salePrice,
            uint16 countryCode
        ) {
                uint256 _boundsKeyUint = uint256(_plotBoundsKey);
                uint256 _id = uintPlotBoundsKeyToPlotListIndex(_boundsKeyUint);
                Plot memory onePlot = plotList[_id];
         
                creationDate = uint64(onePlot.creationDate);
                operationDate = uint64(onePlot.operationDate);
                plotBoundsKey = uint256(onePlot.plotBoundsKey);
                initialPlotPrice = uint256(onePlot.initialPlotPrice);
                lastSalePrice = uint256(onePlot.lastSalePrice);
                isInSale = onePlot.isInSale;
                salePrice = uint256(onePlot.salePrice);
                countryCode= uint16(onePlot.countryCode);
                

        }

        function getPlotWithPlotBoundsKeyUint(uint _boundsKeyUint)  external  view  returns (
     
            uint64 creationDate,       
            uint64 operationDate,
            uint256 plotBoundsKey,
            uint256 initialPlotPrice,
            uint lastSalePrice,
            bool isInSale,
            uint256 salePrice, 
            uint16 countryCode

        ) {
              
                uint256 _id = uintPlotBoundsKeyToPlotListIndex(_boundsKeyUint);
                Plot memory onePlot = plotList[_id];
         
                creationDate = uint64(onePlot.creationDate);
                operationDate = uint64(onePlot.operationDate);
                plotBoundsKey = uint256(onePlot.plotBoundsKey);
                initialPlotPrice = uint256(onePlot.initialPlotPrice);
                lastSalePrice = uint256(onePlot.lastSalePrice);
                isInSale = onePlot.isInSale;
                salePrice = uint256(onePlot.salePrice);
                 countryCode= uint16(onePlot.countryCode);

        }

        function unpause() public onlyCEO whenPaused  returns (bool){
        require(newContractAddress == address(0));
        return super.unpause();

        }


    
   

}

