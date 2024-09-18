// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegrationTest is Test {
    // 4. State variables
    uint256 private constant MINIMUM_USD = 5e18;
    uint256 private constant SEND_VALUE = 0.1 ether;
    uint256 private constant STARTING_VALUE = 1 ether;
    uint256 private constant GAS_PRICE = 1;

    FundMe fundMe;

    address USER = makeAddr("USER");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.deal(USER, STARTING_VALUE);
        fundFundMe.fundFundMe(address(fundMe));

        //address funder = fundMe.getFunder(0);
        //assertEq(funder, USER);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
