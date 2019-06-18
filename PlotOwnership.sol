pragma solidity ^0.4.24;
import "./PlotBase.sol";

contract PlotOwnership is PlotBase {
    uint constant percentageLotteryMoney = 25;
    uint constant percentagePlotAccumulationMoney = 25;
    uint constant percentageSystemMoney = 50;
    uint lotteryMoney=0;
    uint plotAccumulationMoney=0;
    uint systemMoney=0;

    function setAccountBalances(uint moneyValue) public{
        lotteryMoney = lotteryMoney + ((moneyValue * percentageLotteryMoney) / 100);
        plotAccumulationMoney = plotAccumulationMoney + ((moneyValue * percentagePlotAccumulationMoney) / 100);
        systemMoney = systemMoney + ((moneyValue * percentageSystemMoney) / 100);

    }
    function getLotteryMoney() public view returns (uint){
        return lotteryMoney;
    }
    function getPlotAccumulationMoney() public view returns (uint){
        return plotAccumulationMoney;
    }
    function getSystemMoney() public view returns (uint){
        return systemMoney;
    }
 
    uint256 internal saleCount = 0;


    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));


  
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
      
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    function totalSupply() public view returns (uint) {
        return plotList.length-1;
    }


    function balanceOf(address _owner)  public view returns (uint256 count) {
     
        count = ownershipTokenCount[_owner];
    }


    function ownerOf(uint256 _uintPlotBoundsKey) external view returns (address owner) {
        uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(_uintPlotBoundsKey);
        owner = plotListIndexToOwner[plotListIndex];   
         require(owner != address(0)); 
    }
   

    function approve(address _to, uint256 _uintPlotBoundsKey) public {
        address owner = this.ownerOf(_uintPlotBoundsKey);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_uintPlotBoundsKey) != address(0) || _to != address(0)) {
            plotBoundsKeyToApproved[_uintPlotBoundsKey] = _to;
            emit Approval(owner, _to, _uintPlotBoundsKey);
        }
    }


    function _getMinimumCommisionPrice(uint plotListIndex) private returns(uint){
            Plot storage p = plotList[plotListIndex];
            uint plotSalePrice= p.salePrice;
           
            uint plotInitialPrice= getPlotInitialPrice() ;
            uint commisionPrice=0;
             if(plotInitialPrice > plotSalePrice){
                 commisionPrice =plotInitialPrice /  100;  
            }
            else{
                commisionPrice = plotSalePrice/100;
            }
            return commisionPrice;
    }

        function getMinimumCommisionPrice(uint plotBoundsKey) public returns(uint){
             uint plotListIndex = boundsKeyUintToPlotListIndex[plotBoundsKey];
             return _getMinimumCommisionPrice(plotListIndex);
            
        }

    function transfer( address _to,uint256 _uintPlotBoundsKey) external whenNotPaused {
        require(_to != address(0));
        require(_to != msg.sender);
        require(_to != address(this));

        require(_owns(msg.sender, _uintPlotBoundsKey));

    
        _transfer(msg.sender, _to, _uintPlotBoundsKey);
    }

    function isInSalePlot(bytes16 _plotBoundsKey) view public    returns(bool){
        uint256  uintPlotBoundsKey = uint(_plotBoundsKey);
        uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);  
        Plot memory p = plotList[plotListIndex];
        bool resultIsInSale = p.isInSale;
        return resultIsInSale;
    }

    function isInSalePlotUint(uint uintPlotBoundsKey) view public    returns(bool){
        
        uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);  
        Plot memory p = plotList[plotListIndex];
        bool resultIsInSale = p.isInSale;
        return resultIsInSale;
    }
 
    function transferFrom( address _from,address _to,uint256 _uintPlotBoundsKey) public whenNotPaused  payable{
        // Safety check to prevent against an unexpected 0x0 default.
      
        require(isApprovedOrOwner(msg.sender, _uintPlotBoundsKey));
        uint comissionPrice = getMinimumCommisionPrice(_uintPlotBoundsKey);
        require(msg.value >= comissionPrice);
        _buyPlotFromAnother(_from, _to, bytes16(_uintPlotBoundsKey) );
         setAccountBalances(msg.value);
        
    }

    function _buyPlotFromAnother(address previousOwner, address newOwner,bytes16 plotBoundsKey) internal   whenNotPaused {

            uint256  uintPlotBoundsKey = uint(plotBoundsKey);
            uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);
             require(newOwner != address(0));

            require(newOwner != address(this));
            require(previousOwner != newOwner); //can not buy from myself
            require(previousOwner != 0x0); //is on sale
       

            Plot storage p = plotList[plotListIndex];
       

            _transfer(previousOwner,newOwner,uintPlotBoundsKey);
      
            emit BuyPlotFromAnotherEvent(newOwner,previousOwner, plotBoundsKey, p.salePrice); 
            p.lastSalePrice = p.salePrice;
            p.salePrice = 0;  
            p.isInSale = false;  
            delete forsalePlotPreviousOwnerList[uintPlotBoundsKey]; //satış işleminden sonra satış listesinden bu boundsu cıkaracagız
            delete plotBoundsKeyToApproved[uintPlotBoundsKey];//approved listesinden cıkaracagız
            saleCount = saleCount-1;

        }
        function buyPlotFromAnother(bytes16 plotBoundsKey) external  payable whenNotPaused {

            uint256  uintPlotBoundsKey = uint(plotBoundsKey);
            uint256 plotListIndex = uintPlotBoundsKeyToPlotListIndex(uintPlotBoundsKey);
            address previousOwner = forsalePlotPreviousOwnerList[uintPlotBoundsKey];
            Plot storage p = plotList[plotListIndex];       
            require(msg.value >= p.salePrice);
            require(isInSalePlot(plotBoundsKey) == true);
            cutCommisionAndSendEther(previousOwner);
            _buyPlotFromAnother(previousOwner, msg.sender, plotBoundsKey );
        


        }
        function cutCommisionAndSendEther(address to) public payable{
                uint comissionPrice = msg.value / 100;
                uint etherToSend = msg.value - comissionPrice;
                if (!to.send(etherToSend)) {
                        revert(); 
                    }

        }
      
        function isApprovedOrOwner(address _spender,uint256 _tokenId) public view returns (bool){
            address owner = this.ownerOf(_tokenId);
           
            return (
            _spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender)
            );
        }

    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {

       
        uint256 tokenCount =balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalPlots = totalSupply();
            uint256 resultIndex = 0;
            uint256 plotID;
           
            for (plotID = 1; plotID <= totalPlots; plotID++) {
                if (plotListIndexToOwner[plotID] == _owner) {
                    uint256 uintPlotBoundsKey = plotListIndexToBoundsKeyUint[plotID];
                    result[resultIndex] = uintPlotBoundsKey;
                    resultIndex++;
                }
            }

            return result;
        }
    }
 

 
   

  




}

