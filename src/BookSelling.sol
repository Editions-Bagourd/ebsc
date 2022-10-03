// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract BookSelling {
    address public owner;
    address public customer;

    struct Customer {
        address customerAdress;
        string customerName;
    }

    struct Order {
        uint8[] bookIds;
        uint8[] prices;
        uint8[] quantities;
        uint256 date;
        Customer customer;
    }

    function getPrices(uint8[] memory bookIds)
        public
        pure
        returns (uint8[] memory)
    {
        uint8[] memory prices;
        for (uint256 i = 0; i < bookIds.length; i++) {
            prices[i] = 1;
        }
        return prices;
    }

    function getDeliveryFee() public pure returns (uint8) {
        uint8 deliveryFee = 1;
        return deliveryFee;
    }

    function BuyBooks(
        string memory customerName,
        uint8[] memory bookIds,
        uint8[] memory quantities
    ) public payable {
        Customer memory c = Customer(msg.sender, customerName);
        uint8[] memory prices = getPrices(bookIds);
        uint256 date = block.timestamp;
        Order memory order = Order(bookIds, prices, quantities, date, c);
        uint8 deliveryFee = getDeliveryFee();
        uint8 amount = sumProd(prices, quantities) + deliveryFee;
    }

    function sumProd(uint8[] memory array1, uint8[] memory array2)
        public pure
        returns (uint8)
    {
        require(array1.length == array2.length);
        uint8 result = 0;
        for (uint256 i = 0; i < array1.length; i++) {
            result += array1[i] * array2[i];
        }
        return result;
    }
}
