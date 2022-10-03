// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BookSelling.sol";
import "openzepplin-contracts/contracts/token/ERC20/IERC20.sol";


contract BookSellingTest is Test {
    BookSelling bookSelling;
    address CUSTOMER = 0x19D675bBb76946785249A3AD8a805260e9420CB8;
    address EB = 0xaC156478FA93293cc7B0DBD5FbE7e2e9Abe1f121;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    function setUp() public {
        bookSelling = new BookSelling();
    }

    
    function testShouldBuyABook() public {
        bookSelling.setEditionsBagourd(EB);
        console.log("book contract",address(bookSelling));

        assertTrue(bookSelling.editionsBagourd()==EB);
        string memory customerName = "Customer1";
        uint256[] memory bookIds = new uint256[](3);
        bookIds[0]=1;
        bookIds[1]=2;
        bookIds[2]=3;
        uint256[] memory quantities = new uint256[](3);
        quantities[0]=1;
        quantities[1]=1;
        quantities[2]=1;

        IERC20 usdc = IERC20(address(USDC));
        uint256 startingBalance = usdc.balanceOf(EB);
        
        vm.startPrank(CUSTOMER);
        uint256 amountToPay = bookSelling.getAmountToPay(bookIds,quantities);
        console.log("amount",amountToPay);
        // customer approving contract
        usdc.approve(address(bookSelling), amountToPay);

        bookSelling.BuyBooks(
            customerName,
            bookIds,
            quantities,
            usdc
        );
        vm.stopPrank();
        assertTrue(startingBalance +amountToPay == usdc.balanceOf(EB));
    }

    function testShouldRevertWhenTryingToBuyANonExistingBook() public {
        uint256[] memory bookIds = new uint256[](1);
        uint256[] memory quantities = new uint256[](1);
        // Non existing book id
        bookIds[0]=10;
        quantities[0] = 1;

        vm.expectRevert("You are trying to buy a non existing book");
        uint256 amountToPay = bookSelling.getAmountToPay(bookIds,quantities);
        console.log(amountToPay);
    }

}

