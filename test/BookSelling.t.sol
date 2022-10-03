// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BookSelling.sol";

contract BookSellingTest is Test {
    function setUp() public {}

    function testExample() public {
        assertTrue(true);
    }

    function testSumProd() public {
        uint8[] memory array1 = new uint8[](3);
        array1[0] = 1;
        array1[1] = 1;
        array1[2] = 1;
        uint8[] memory array2 = new uint8[](3);
        array2[0] = 1;
        array2[1] = 2;
        array2[2] = 3;
        uint8 sp = sumProd(array1,array2);
        console.log(sp);
        assert(sp==6);
        
    }


    function sumProd(uint8[] memory array1, uint8[] memory array2)
        public pure
        returns (uint8)
    {
        require(array1.length == array2.length);
        uint8 result = 0;
        for (uint256 i = 0; i < array1.length; i++) {
            result = result + array1[i] * array2[i];
        }
        return result;
    }
}
