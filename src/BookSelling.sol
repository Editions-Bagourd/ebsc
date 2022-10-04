// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzepplin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzepplin-contracts/contracts/access/Ownable.sol";
import "openzepplin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";


contract BookSelling is Ownable{
    using SafeERC20 for IERC20;


    address public editionsBagourd;
    address public customer;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 deliveryFee; // in USD equivalent
    uint256 nonce;

    mapping(address => bool) public supportedTokens;
    mapping(uint256 => uint256) public bookIdsToPrices; // in USD equivalent
    mapping(uint256 => uint256) public bookIdsToStocks;
    mapping(uint256 => Book) public bookIdsToBooks;

    struct Book {
        uint256 bookId;
        uint256 price;
        string title;
    }

    struct Customer {
        address customerAddress;
        string customerName;
    }

    struct Order {
        uint256[] bookIds;
        uint256[] prices;
        uint256[] quantities;
        uint256 date;
        Customer customer;
    }

    event order (uint256, uint256[], uint256[], uint256[], uint256, Customer);
    event invoice (address, address, uint256, uint256);

    constructor() Ownable() {
        setEditionsBagourd(0xfaa2A775b035314e9Ac10C2938D28E2554D70792);
        setSupportedTokens();
        setDeliveryFee(10);
        addBook(1, "Up From Slavery", 14, 10);
    }

    function setEditionsBagourd(address a) public onlyOwner {
        editionsBagourd=a;
    }

    function setSupportedTokens() public onlyOwner {
        supportedTokens[USDC]=true;
        supportedTokens[USDT]=true;
        supportedTokens[DAI]=true;
    }

    function supportToken(address token) public onlyOwner {
        supportedTokens[token] = true;
    }

    function unsupportToken(address token) public onlyOwner {
        supportedTokens[token] = false;
    }

    function updatePrice(uint256 bookId, uint256 price) public onlyOwner {
        bookIdsToPrices[bookId] = price;
    }

    function updateQuantity(uint256 bookId, uint256 quantity) public onlyOwner {
        bookIdsToStocks[bookId] = quantity;
    }

    function updateQuantities(uint256[] memory bookIds, uint256[] memory quantities) internal {
        for (uint i = 0; i < bookIds.length; i++) {
            bookIdsToStocks[bookIds[i]] -= quantities[i];
        }
    }

    function addBook(uint256 bookId, string memory title, uint256 price, uint256 quantity)  public onlyOwner  {
        Book memory book = Book(bookId, price, title);
        bookIdsToStocks[bookId] += quantity;
        bookIdsToPrices[bookId] = price;
        bookIdsToBooks[bookId] = book;
    }

    function setDeliveryFee(uint256 fee) public onlyOwner {
        deliveryFee = fee;
    }

    function getDeliveryFee() public view returns(uint256) {
        return deliveryFee;
    }

    function getPrices(uint256[] memory bookIds)
        public view
        returns (uint256[] memory)
    {
        uint256[] memory prices = new uint256[](bookIds.length);
        uint256 p;
        for (uint i = 0; i < bookIds.length; i++) {
            p = bookIdsToPrices[bookIds[i]];
            require(p>0, "You are trying to buy a non existing book");
            prices[i] = p;
        }
        return prices;
    }

    function getAmountToPay(
        uint256[] memory bookIds,
        uint256[] memory quantities
    ) public view
    returns(uint256) {
        uint256[] memory prices = getPrices(bookIds);
        uint256 amount = sumProd(prices, quantities) + deliveryFee;
        return amount;
    }

    function checkBooksAreAvailable(uint256[] memory bookIds, uint256[] memory quantities) view public {
        for (uint256 i = 0; i < bookIds.length; i++) {
            require(bookIdsToStocks[bookIds[i]]>=quantities[i], "Book out of stock.");
        }
    }

    function buyBooks(
        string memory customerName,
        uint256[] memory bookIds,
        uint256[] memory quantities,
        IERC20 erc20
    ) public 
    {
        require(supportedTokens[address(erc20)], "Token not supported.");
        require(bookIds.length == quantities.length);
        Customer memory c = Customer(msg.sender, customerName);
        checkBooksAreAvailable(bookIds, quantities);
        uint256[] memory prices = getPrices(bookIds);
        uint256 date = block.timestamp;
        uint256 orderId = getID();
        emit order(orderId, bookIds, prices, quantities, date, c);
        uint256 amount = getAmountToPay(bookIds, quantities);
        erc20.safeTransferFrom(msg.sender, editionsBagourd, amount);
        emit invoice(msg.sender, editionsBagourd, amount, orderId);
        updateQuantities(bookIds, quantities);
    }

    function sumProd(uint256[] memory array1, uint256[] memory array2)
        public pure
        returns (uint256)
    {
        require(array1.length == array2.length);
        uint256 result = 0;
        for (uint256 i = 0; i < array1.length; i++) {
            result += array1[i] * array2[i];
        }
        return result;
    }

    function getID() internal returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number,msg.sender, nonce++)));
    }
}
