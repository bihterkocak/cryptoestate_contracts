pragma solidity ^0.4.24;



contract  BoundsCheck {


    /*** 1 FOR POSITIVE 0 FOR NEGATIVE DIGITS **/
    /***GET COORDINATES**/
    function getNorthLatitude (bytes16 plotBoundsKey) public pure returns(byte[4] northLatitude) {
        northLatitude[0] = plotBoundsKey[0];
        northLatitude[1] = plotBoundsKey[1];
        northLatitude[2] = plotBoundsKey[2];
        northLatitude[3] = plotBoundsKey[3];
    }

    function getEastLongitude (bytes16 plotBoundsKey) public pure returns(byte[4] eastLongitude) {
        eastLongitude[0] = plotBoundsKey[4];
        eastLongitude[1] = plotBoundsKey[5];
        eastLongitude[2] = plotBoundsKey[6];
        eastLongitude[3] = plotBoundsKey[7];
    }

    function getSouthLatitude (bytes16 plotBoundsKey) public pure returns(byte[4] southLatitude) {
        southLatitude[0] = plotBoundsKey[8];
        southLatitude[1] = plotBoundsKey[9];
        southLatitude[2] = plotBoundsKey[10];
        southLatitude[3] = plotBoundsKey[11];
    }

    function getWestLongitude (bytes16 plotBoundsKey) public pure returns(byte[4] westLongitude) {
        westLongitude[0] = plotBoundsKey[12];
        westLongitude[1] = plotBoundsKey[13];
        westLongitude[2] = plotBoundsKey[14];
        westLongitude[3] = plotBoundsKey[15];
    }


    function isLastDigitOfByteZero(byte b) public pure returns(bool) {
        int lastDigit = int(b) % 16;

        if (lastDigit != 0) {
            return false;
        }
        else {
            return true;
        }
    }
    function checkNorthLatitudeLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {


        byte[4] memory northLatitude = getNorthLatitude(plotBoundsKey);
     
        int northLatitudeLastDigit = int(northLatitude[3]) % 16;
        if (northLatitudeLastDigit == int(0)) {
            return true;
        }
        else {
            return false;
        }
    }

    function checkEastLongitudeLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {
        byte[4] memory eastLongitude = getEastLongitude(plotBoundsKey);
        int eastLongitudeLastDigit = int(eastLongitude[3]) % 16;
        if (eastLongitudeLastDigit != 0) {
            return false;
        }
        else {
            return true;
        }
    }

    function checkSouthLatitudeLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {
        byte[4] memory southLatitude = getSouthLatitude(plotBoundsKey);
        int southLatitudeLastDigit = int(southLatitude[3]) % 16;
        if (southLatitudeLastDigit != 0) {
            return false;
        }
        else {
            return true;
        }
    }

    function checkWestLongitudeLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {
        byte[4] memory westLongitude = getWestLongitude(plotBoundsKey);
        int westLongitudeLastDigit = int(westLongitude[3]) % 16;
        if (westLongitudeLastDigit != 0) {
            return false;
        }
        else {
            return true;
        }
    }


    function checkNorthLatitudeSecondLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {

        byte[4] memory northLatitude = getNorthLatitude(plotBoundsKey);
        int northLatitudeLastDigit = int(northLatitude[3]) / 16;
        if (northLatitudeLastDigit % 2 != 0) {
            return false;
        }
        else {
            return true;
        }
    }

    function checkEastLongitudeSecondLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {
        byte[4] memory eastLongitude = getEastLongitude(plotBoundsKey);
        int eastLongitudeLastDigit = int(eastLongitude[3]) / 16;
        if (eastLongitudeLastDigit % 2 != 0) {
            return false;
        }
        else {
            return true;
        }
    }

    function checkSouthLatitudeSecondLastDigit (bytes16 plotBoundsKey) public pure returns(bool) {
        byte[4] memory southLatitude = getSouthLatitude(plotBoundsKey);
        int southLatitudeLastDigit = int(southLatitude[3]) / 16;
        if (southLatitudeLastDigit % 2 != 0) {
            return false;
        }
        else {
            return true;
        }
    }

    function checkWestLongitudeSecondLastDigit (bytes16 plotBoundsKey) public pure returns (bool) {
        byte[4] memory westLongitude = getWestLongitude(plotBoundsKey);
        int westLongitudeLastDigit = int(westLongitude[3]) / 16;
        if (westLongitudeLastDigit % 2 != 0) {
            return false;
        }
        else {
            return true;
        }
    }



    function isNorthLatitudeGreaterThanSouthLatitude (bytes16 plotBoundsKey) public pure returns(bool) {
          byte[4] memory  northLatitude = getNorthLatitude(plotBoundsKey);
           byte[4]  memory southLatitude = getSouthLatitude(plotBoundsKey);

            int southLatitudeFirstLastDigit = int(southLatitude[0]) / 16;
            int northLatitudeSecondFirstDigit = int(northLatitude[0]) / 16;
           
           for (uint index = 0; index < 4; index++) {
               byte bs = southLatitude[index];
               byte bn = northLatitude[index];
                 if (southLatitudeFirstLastDigit == 1 && northLatitudeSecondFirstDigit == 1) {
                    if (bn > bs) {
                        return true;
                    }
                 }
                   if (southLatitudeFirstLastDigit == 0 && northLatitudeSecondFirstDigit == 0) {
                    if (bs > bn) {
                        return true;
                    }
                 }
               if (bn == bs) {
                   continue;
               }
               else{
                    return false;
                    }

           }
           return false;
    }

    function isEastLongitudeGreaterThanWestLongitude (bytes16 plotBoundsKey) public pure returns(bool) {
     
           byte[4] memory  westLongitude = getWestLongitude(plotBoundsKey);
           byte[4]  memory eastLongitude = getEastLongitude(plotBoundsKey);

                   int eastLongitudeFirstDigit = int(eastLongitude[0]) / 16;
                   int westLongitudeFirstDigit = int(westLongitude[0]) / 16;
           
           for (uint index = 0; index < 4; index++) {
               byte bw = westLongitude[index];
               byte be = eastLongitude[index];
                 if (eastLongitudeFirstDigit == 1 && westLongitudeFirstDigit == 1) {
                    if (be > bw) {
                        return true;
                    }
                 }
                  if (eastLongitudeFirstDigit == 0 && westLongitudeFirstDigit == 0) {
                    if (bw > be) {
                        return true;
                    }
                 }
               if (be == bw) {
                   continue;
               }
               else{
                    return false;
                    }

           }
           return false;
           
   
    }

    function isEastLongitudeSecondLastDigitMinusWestLongitudeSecondLastDigitIsTwo(bytes16 plotBoundsKey)  public pure returns(bool){

        byte[4] memory eastLongitude = getEastLongitude(plotBoundsKey);
        int eastLongitudeSecondLastDigit = int(eastLongitude[3]) / 16;
        int eastLongitudeFirstDigit = int(eastLongitude[0]) / 16;

        byte[4] memory westLongitude = getWestLongitude(plotBoundsKey);
        int westLongitudeSecondLastDigit = int(westLongitude[3]) / 16;
        int westLongitudeFirstDigit = int(westLongitude[0]) / 16;
         if (eastLongitudeFirstDigit == 1 && westLongitudeFirstDigit == 1) {
            if (eastLongitudeSecondLastDigit == 0){ 
                    /*if last digit 0 it means last digit 10 */
                    eastLongitudeSecondLastDigit = 10;
                }
         }

           if (eastLongitudeFirstDigit == 0 && westLongitudeFirstDigit == 0) {
            if (westLongitudeSecondLastDigit == 0){ 
                    /*if last digit 0 it means last digit 10 */
                    westLongitudeSecondLastDigit = 10;
                }
         }
        int eastMinusWest = eastLongitudeSecondLastDigit - westLongitudeSecondLastDigit;
        int westMinusEastForNegativeValue = westLongitudeSecondLastDigit-eastLongitudeSecondLastDigit;

     

        if (eastLongitudeFirstDigit == 0 && westLongitudeFirstDigit == 0) {
            if (westMinusEastForNegativeValue == 2){
                return true;
            }
            else {
                return false;
            }
        }
        else {
            if (eastMinusWest == 2) {
                return true;
            }
            else {
                return false;
            }
        }

    }

    function isNorthLatitudeSecondLastDigitMinusSouthLatitudeSecondLastDigitIsTwo(bytes16 plotBoundsKey)  public pure returns(bool){
  
        byte[4] memory southLatitude = getSouthLatitude(plotBoundsKey);
        int southLatitudeSecondLastDigit = int(southLatitude[3]) / 16;
        int southLatitudeFirstLastDigit = int(southLatitude[0]) / 16;
        byte[4] memory northLatitude = getNorthLatitude(plotBoundsKey);
        int northLatitudeSecondLastDigit = int(northLatitude[3]) / 16;
        int northLatitudeSecondFirstDigit = int(northLatitude[0]) / 16;

         if (southLatitudeFirstLastDigit == 1 && northLatitudeSecondFirstDigit == 1) {
                if (northLatitudeSecondLastDigit == 0){ 
                    /*if last digit 0 it means last digit 10 */
                    northLatitudeSecondLastDigit = 10;
                }
         }

             if (southLatitudeFirstLastDigit == 0 && northLatitudeSecondFirstDigit == 0) {
            if (southLatitudeSecondLastDigit == 0){ 
                    /*if last digit 0 it means last digit 10 */
                    southLatitudeSecondLastDigit = 10;
                }
         }

       



        int northMinusSouth = northLatitudeSecondLastDigit - southLatitudeSecondLastDigit;
        int southMinusNorthForNegativeValue = southLatitudeSecondLastDigit - northLatitudeSecondLastDigit;

        if (southLatitudeFirstLastDigit == 0 && northLatitudeSecondFirstDigit == 0) {
            if (southMinusNorthForNegativeValue == 2) {
                return true;
            }
            else {
                return false;
            }
        }
        else {
            if (northMinusSouth == 2) {
                return true;
            }
            else {
                return false;
            }
        }

    }

/***END OF IS FUNCTIONS FOR REQUIREMENTS**/


    function checkCorrectness (bytes16 plotBoundsKey) public  pure returns(bool) {
    return (
        checkNorthLatitudeLastDigit(plotBoundsKey) &&
        checkEastLongitudeLastDigit(plotBoundsKey) &&
        checkSouthLatitudeLastDigit(plotBoundsKey) &&
        checkWestLongitudeLastDigit(plotBoundsKey) &&
        checkNorthLatitudeSecondLastDigit(plotBoundsKey) &&
        checkEastLongitudeSecondLastDigit(plotBoundsKey) &&
        checkSouthLatitudeSecondLastDigit(plotBoundsKey) &&
        checkWestLongitudeSecondLastDigit(plotBoundsKey) &&
        isEastLongitudeSecondLastDigitMinusWestLongitudeSecondLastDigitIsTwo(plotBoundsKey) &&
        isNorthLatitudeSecondLastDigitMinusSouthLatitudeSecondLastDigitIsTwo(plotBoundsKey) &&
        isNorthLatitudeGreaterThanSouthLatitude(plotBoundsKey) &&
        isEastLongitudeGreaterThanWestLongitude(plotBoundsKey) 

    ); 



    return true;

    }


}