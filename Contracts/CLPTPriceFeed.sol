// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CLPTPriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    constructor() public {
        priceFeed = AggregatorV3Interface(0xeEfF5Ab40897377306b7C3D39d4e073883D74B99); // Rinkeby ETH/USD price
    }

    function getThePrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}