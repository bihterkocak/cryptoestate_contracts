pragma solidity ^0.4.24;

import "./PlotOperation.sol";


contract PlotAccumulation is PlotOperation {
 

    function getPlotCreationDateWithIndex(uint index)  public view  returns ( uint64 creationDate) {              
        Plot memory onePlot = plotList[index];        
        creationDate = uint64(onePlot.creationDate);

    }
 
    function withdrawBalance() external onlyCFO {    
        cfoAddress.transfer(systemMoney);
        systemMoney = 0;
          
    }    


 

 
}