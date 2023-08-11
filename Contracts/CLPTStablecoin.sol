// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CLPTStablecoin is ERC20 {
    using SafeMath for uint256;

    address public admin;
    IERC20 public collateralToken;
    AggregatorV3Interface public priceFeed;

    uint public constant COLLATERAL_DECIMAL = 1e6;

    constructor(
        address _collateralToken,
        address _pricefeed
    ) ERC20("Chilean Pesos Token", "CLPT") {
        require(
            _collateralToken != address(0),
            "Invalid collateral token address"
        );
        require(_pricefeed != address(0), "Invalid price feed address");

        admin = msg.sender;
        collateralToken = IERC20(_collateralToken);
        priceFeed = AggregatorV3Interface(_pricefeed);
    }

    function getCollateralPrice() public view returns (uint) {
        (, int price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed");
        return uint(price);
    }

    function calculateCollateralAmount(
        uint _stablecoinAmount
    ) public view returns (uint) {
        uint collateralprice = getCollateralPrice();
        return _stablecoinAmount.mul(COLLATERAL_DECIMAL).div(collateralprice);
    }

    function mint(uint _stablecoinAmount) external {
        require(_stablecoinAmount > 0, "Invalid stablecoin amount");

        uint collateralAmount = calculateCollateralAmount(_stablecoinAmount);
        collateralToken.transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        _mint(msg.sender, _stablecoinAmount);
    }

    function burn(uint _stablecoinAmount) external {
        require(_stablecoinAmount > 0, "Invalid stablecoin amount");

        uint collateralAmount = calculateCollateralAmount(_stablecoinAmount);
        _burn(msg.sender, _stablecoinAmount);
        collateralToken.transfer(msg.sender, collateralAmount);
    }
}