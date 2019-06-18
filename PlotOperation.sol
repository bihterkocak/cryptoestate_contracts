pragma solidity ^0.4.24;


import "./PlotOwnership.sol";
import "./ERC721Receiver.sol";




contract PlotOperation is PlotOwnership {

  

        bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

        function buyPlotFromCryptoEstate(bytes16 plotBoundsKey,uint16 countryCode) public  payable whenNotPaused {
          require (msg.value >= getPlotInitialPrice());
            _createPlot(plotBoundsKey,countryCode, msg.sender);
            emit BuyPlotFromCryptoEstateEvent(msg.sender,plotBoundsKey);
            setAccountBalances(msg.value);
        

          
        }
        function buyPlotFromCryptoEstateMultiple(bytes16[] plotBoundsKeyList,uint16[] countryCodeList) public  payable whenNotPaused{
             uint howManyPlots = plotBoundsKeyList.length;
           
            require(msg.value >= getPlotInitialPrice() * howManyPlots);
         
           for (uint i = 0; i < plotBoundsKeyList.length; i++){
                     bytes16 plotBoundsKey = plotBoundsKeyList[i];
                     uint16 countryCode =  countryCodeList[i];
                      _createPlot(plotBoundsKey,countryCode, msg.sender);
                       
                     emit BuyPlotFromCryptoEstateEvent(msg.sender,plotBoundsKey);
                    setAccountBalances(msg.value);
            }
          
        }
        //bir de tek country code lu olanı yapılabilir


   
        function transferPromotionPlot(bytes16 plotBoundsKey, address newOwner) whenNotPaused onlyCFO public{
        
            uint256  uintPlotBoundsKey = uint(plotBoundsKey);
            uint promotionIndex = boundsKeyUintToPlotListIndex[uintPlotBoundsKey];
            require(promotionIndex < promotionPlotMaxIndex);
            bool isAlreadyTransfered = promotionPlotListTransfer[promotionIndex];
             require (isAlreadyTransfered == false);
            _transfer(msg.sender,newOwner,uintPlotBoundsKey);
             promotionPlotListTransfer[promotionIndex] = true;
            emit TransferPromotionPlotEvent(plotBoundsKey,  newOwner);

        }

      
        function putOnSale( bytes16 _plotBoundsKey, uint256 _plotSalePrice) public whenNotPaused {

            uint256  uintPlotBoundsKey = uint(_plotBoundsKey);

            require(_plotSalePrice >= getMinimumSalePrice());
            require(_ownsBytes16(msg.sender,_plotBoundsKey) == true);
            require(checkCorrectness(_plotBoundsKey));      
            require(isInSalePlot(_plotBoundsKey) == false); 

            uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);            
            Plot storage p = plotList[plotListIndex];
            p.salePrice = _plotSalePrice;  
            p.isInSale = true;  
            forsalePlotPreviousOwnerList[uintPlotBoundsKey] = msg.sender;


            emit PutOnSaleEvent(_plotBoundsKey,_plotSalePrice,msg.sender);
            saleCount = saleCount + 1;


        }

        function removeOnSale( bytes16 _plotBoundsKey) public whenNotPaused{

            uint256  uintPlotBoundsKey = uint(_plotBoundsKey);
            require(msg.sender != address(0x0));
            require(_ownsBytes16(msg.sender,_plotBoundsKey) == true);
            require(checkCorrectness(_plotBoundsKey));      
            require(isInSalePlot(_plotBoundsKey) == true);


            uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);            
            Plot storage p = plotList[plotListIndex];
            p.salePrice = 0;  
            p.isInSale = false;  
            delete forsalePlotPreviousOwnerList[uintPlotBoundsKey]; 
            delete plotBoundsKeyToApproved[uintPlotBoundsKey];


            emit RemoveOnSaleEvent(_plotBoundsKey,msg.sender);
            saleCount = saleCount-1;
       

        }

        function getSalePrice(bytes16 _plotBoundsKey) view public   returns  (uint256){
            uint256  uintPlotBoundsKey = uint(_plotBoundsKey);
            uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);  
            Plot memory p = plotList[plotListIndex];
            uint256 resultPrice = p.salePrice;
            return resultPrice;
        }

  
        function getAllForsalePlotsList() view public   returns(uint256[]){
            uint256[] memory forsalePlotList = new uint[](saleCount);

            uint256 totalPlots = totalSupply();
            uint256 plotListIndex;
            uint currentCount = 0;
            for (plotListIndex = 1; plotListIndex <= totalPlots; plotListIndex++) {
                Plot memory p = plotList[plotListIndex];
                if (p.salePrice > 0) {
                    uint256  uintPlotBoundsKey = uint(p.plotBoundsKey);
                    forsalePlotList[currentCount] = uintPlotBoundsKey;
                    currentCount = currentCount+ 1;
                }
            }

            return forsalePlotList;

        }

       
       

           function getAllPlotsList() public view   returns(uint256[]){
                return getAllPlotsListWithIndex(1);

        }
        
        function getAllPlotsListWithIndex(uint startIndex) public   view returns(uint256[]){
                 uint256 totalPlots = totalSupply() + 1;
                 uint256 remainingPlots = totalPlots - startIndex;
            uint256[] memory allPlotKeyList = new uint[](remainingPlots);
         
          
            uint256 plotListIndex;
               uint256 allPlotKeyListIndex = 0;
        
            for (plotListIndex = startIndex; plotListIndex < totalPlots; plotListIndex++) {

                    allPlotKeyList[allPlotKeyListIndex] = plotListIndexToBoundsKeyUint[plotListIndex];    
                    allPlotKeyListIndex = allPlotKeyListIndex + 1;                          
            }

            return allPlotKeyList;


        }
     
          
        function isContract(address addr) internal view returns (bool) {
            uint256 size;
            
            assembly { size := extcodesize(addr) }
            return size > 0;
        }

      
        
        function checkAndCallSafeTransfer(address _from, address _to,  uint256 _tokenId, bytes _data)  internal  returns (bool){
                if (!isContract(_to)) {
                    return true;
                }
                bytes4 retval = ERC721Receiver(_to).onERC721Received(
                _from, _tokenId, _data);
                return (retval == ERC721_RECEIVED);
        }


        function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public payable  canTransfer(_tokenId){
            transferFrom(_from, _to, _tokenId);
            require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));            
        }

        function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable canTransfer(_tokenId){
                  safeTransferFrom(_from, _to, _tokenId, "");
        }
      
        function setApprovalForAll(address _to, bool _approved) public{
            require(_to != msg.sender);
            operatorApprovals[msg.sender][_to] = _approved;
            emit ApprovalForAll(msg.sender, _to, _approved);
        }

        function getApproved(uint256 _tokenId) public view returns (address){

          return plotBoundsKeyToApproved[_tokenId];

        }


        function isApprovedForAll(address _owner, address _operator) public view returns (bool){
              return operatorApprovals[_owner][_operator];

        }

        function supportsInterface(bytes4 interfaceID) external view returns (bool){
            return true;
        }
        function name() public view returns (string _name){
         return "CryptoEstate";
        }
        function symbol() public view returns (string _symbol){
             return "CE";
            
        }
        
        modifier canTransfer(uint256 _tokenId) {
            require(isApprovedOrOwner(msg.sender, _tokenId));
            _;
        }
  


     
 
     
}