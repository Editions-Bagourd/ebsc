// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzepplin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzepplin-contracts/contracts/access/Ownable.sol";
import "openzepplin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";


contract BookSelling is Ownable{
    using SafeERC20 for IERC20;


    
    //address public owner;
    address public editionsBagourd;
    address public customer;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 deliveryFee;

    mapping(address => bool) public supportedTokens;
    mapping(uint256 => uint256) public bookIdsToPrices;



    constructor() public Ownable() {
        //owner=msg.sender;
    }

    function setEditionsBagourd(address a) public onlyOwner {
        editionsBagourd=a;
        setSupportedTokens();
        setPrice(1,1);
        setPrice(2,1);
        setPrice(3,1);
        setDeliveryFee(10);
    }

    function setSupportedTokens() public onlyOwner {
        supportedTokens[USDC]=true;
        supportedTokens[USDT]=true;
        supportedTokens[DAI]=true;
    }

    function setPrice(uint256 bookId, uint256 price) public onlyOwner {
        bookIdsToPrices[bookId] = price;
    }

    function setDeliveryFee(uint256 fee) public onlyOwner {
        deliveryFee = fee;
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

    function getPrices(uint256[] memory bookIds)
        public
        view
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

    function getDeliveryFee() public view returns (uint256) {
        return deliveryFee;
    }

    function getAmountToPay(
        uint256[] memory bookIds,
        uint256[] memory quantities
    ) public view
    returns(uint256) {
        uint256[] memory prices = getPrices(bookIds);
        uint256 amount = sumProd(prices, quantities) + getDeliveryFee();
        return amount;
    }

    function BuyBooks(
        string memory customerName,
        uint256[] memory bookIds,
        uint256[] memory quantities,
        IERC20 erc20
    ) public payable 
    {
        require(supportedTokens[address(erc20)], "Token not supported.");
        Customer memory c = Customer(msg.sender, customerName);
        uint256[] memory prices = getPrices(bookIds);
        uint256 date = block.timestamp;
        Order memory order = Order(bookIds, prices, quantities, date, c);
        uint256 amount = getAmountToPay(bookIds, quantities);

        erc20.safeTransferFrom(msg.sender, editionsBagourd, amount);
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
}
