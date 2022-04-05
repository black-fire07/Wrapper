// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

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
    IERC20 usdt;
    uint256 constant rate = 75;

    MyToken public token;
    constructor( address _usdt, address _token){
        usdt = IERC20(_usdt);
        token = MyToken(_token);
    }


    function payusdt(uint256 amount) public {
        uint256 _amount = amount * 10**18;

        usdt.transferFrom(msg.sender, address(this), _amount);
        token.mint(msg.sender, rate * _amount);
    }

    function getusdt(uint256 amount) public {
        uint256 _amount = amount * 10**18;

        token.transferFrom(msg.sender,address(this), _amount);
        token.burn(_amount);
        usdt.transfer(msg.sender, _amount/rate);
    }    


    function withdrawAllusdt() external onlyOwner{
        usdt.transfer(owner(),usdt.balanceOf(address(this)));
    }

}
