// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BookSelling.sol";
import "openzepplin-contracts/contracts/token/ERC20/IERC20.sol";


contract BookSellingTest is Test {
    BookSelling bookSelling;
    address CUSTOMER = 0x19D675bBb76946785249A3AD8a805260e9420CB8;
    address EB = 0xfaa2A775b035314e9Ac10C2938D28E2554D70792;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    function setUp() public {
        bookSelling = new BookSelling();
    }

    function testAddABook() public {
        bookSelling.addBook(1, "Up From Slavery", 14, 10);
        string memory title;
        uint256 bookId;
        uint256 price;
        (bookId, price, title) = bookSelling.bookIdsToBooks(1);
        assertTrue(keccak256(bytes(title))==keccak256(bytes("Up From Slavery")));
    }

    function testShouldRevertWhenTryingToBuyOutOfStockBook() public{
        bookSelling.addBook(1, "Up From Slavery", 14, 10);
        string memory customerName = "Customer1";
        uint256[] memory bookIds = new uint256[](1);
        bookIds[0]=1;
        uint256[] memory quantities = new uint256[](1);
        quantities[0]=11;
        IERC20 usdc = IERC20(address(USDC));
        uint256 amountToPay = bookSelling.getAmountToPay(bookIds,quantities);
        vm.startPrank(CUSTOMER);
        // customer approving contract
        usdc.approve(address(bookSelling), amountToPay);
        vm.expectRevert("Book out of stock.");
        bookSelling.buyBooks(
            customerName,
            bookIds,
            quantities,
            usdc
        );
        vm.stopPrank();
    }

    function testShouldBuyBooks() public {
        bookSelling.addBook(1, "Up From Slavery", 14, 10);
        bookSelling.addBook(2, "Harry Potter", 10, 10);
        bookSelling.addBook(3, "LOTR", 8, 12);
        console.log("book contract",address(bookSelling));
        assertTrue(bookSelling.editionsBagourd()==EB);

        string memory customerName = "Customer1";
        uint256[] memory bookIds = new uint256[](3);
        bookIds[0]=1;
        bookIds[1]=2;
        bookIds[2]=3;
        uint256[] memory quantities = new uint256[](3);
        quantities[0]=1;
        quantities[1]=2;
        quantities[2]=1;

        IERC20 usdc = IERC20(address(USDC));
        uint256 startingBalance = usdc.balanceOf(EB);
        
        vm.startPrank(CUSTOMER);
        uint256 amountToPay = bookSelling.getAmountToPay(bookIds,quantities);
        console.log("amount",amountToPay);
        // customer approving contract
        usdc.approve(address(bookSelling), amountToPay);

        bookSelling.buyBooks(
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


struct Book {
        uint256 bookId;
        uint256 price;
        string title;
    }