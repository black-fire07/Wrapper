// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MyToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    function burn(uint256 amount) public onlyRole(MINTER_ROLE) {
        _burn(msg.sender, amount);
    }
}


contract Wrapper is Ownable{
    IERC20 inr_usdt;
    MyToken public token;
    AggregatorV3Interface internal priceFeed;

    constructor( address _inr_usdt, address _token){
        priceFeed = AggregatorV3Interface(0x605D5c2fBCeDb217D7987FC0951B5753069bC360);
        inr_usdt = IERC20(_inr_usdt);
        token = MyToken(_token);
    }

    function getPrice() public view returns(uint){
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint(price);
    }

    function payINR(uint256 amount) public {
        uint256 _amount = amount * getPrice() * 10**18;

        inr_usdt.transferFrom(msg.sender, address(this), _amount);
        token.mint(msg.sender, _amount);
    }

    function getinr(uint256 amount) public {
        uint256 _amount = amount * getPrice() * 10**18;

        token.transferFrom(msg.sender,address(this), _amount);
        token.burn(_amount);
        inr_usdt.transfer(msg.sender, _amount);
    }    


    function withdrawAllinr_usdt() external onlyOwner{
        inr_usdt.transfer(owner(),inr_usdt.balanceOf(address(this)));
    }

}
