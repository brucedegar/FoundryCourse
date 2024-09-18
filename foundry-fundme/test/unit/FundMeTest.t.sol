// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // 4. State variables
    uint256 private constant MINIMUM_USD = 5e18;
    uint256 private constant SEND_VALUE = 0.1 ether;
    uint256 private constant STARTING_VALUE = 1 ether;
    uint256 private constant GAS_PRICE = 1;

    FundMe fundMe;

    address USER = makeAddr("USER");

    // 8. Constructor

    // when we run forge test and we dont give RPC URL then it will spin up a new blank Anvil chain and test
    // our tests
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_VALUE); // Set USER's balance to STARTING_VALUE

        // When you run forge test, your Solidity contract is deployed in a local Ethereum-like environment provided by Foundry, the testing framework you are using
        // In this case should be Anvil
        // Tests are deployed to 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84. If you deploy a contract within your test, then 0xb4c...7e84 will be its deployer. If the contract deployed within a test gives special permissions to its deployer, such as Ownable.sol’s onlyOwner modifier, then the test contract 0xb4c...7e84 will have those permissions.
        console.log("Owner Address: ", address(this));
        //   Owner Address:  0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        //   Fundme Address:  0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    }

    function testMinimumFiveDollar() public view {
        // Arrange
        // Act
        // Assert
        console.log("Fundme Address : ", address(fundMe));
        assertEq(fundMe.MINIMUM_USD(), MINIMUM_USD);
    }

    function testOwnerIsMsgSender() public view {
        // Arrange
        // Act
        // Assert
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAccurateVersion() public view {
        /*
            [10206] FundMeTest::testAccurateVersion()
            ├─ [5121] FundMe::getVersion() [staticcall]
            │   ├─ [0] 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF::version() [staticcall]
            │   │   └─ ← [Stop] 
            │   └─ ← [Revert] EvmError: Revert
            └─ ← [Revert] EvmError: Revert
        */

        // This test will fail because the address 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF is not the same chain
        // So it does not exist for local chain

        // forge test --mt testAccurateVersion -vvvv --fork-url $SEPOLIA_RPC_URL

        // Arrange
        // Act
        // Assert
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailesWithoutEnoughEth() public {
        // Arrange
        console.log("ethAmount : ", SEND_VALUE);
        // Act
        vm.expectRevert(); // Expect next line to revert

        fundMe.fund{value: 1}();
        // Assert
    }

    function testFundSuccessWithEnoughEth() public {
        // Arrange
        vm.prank(USER); // Next transaction will be from USER

        // Act
        fundMe.fund{value: SEND_VALUE}();
        // Assert
        assertEq(fundMe.getFunder(0), USER);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddFunderToFundersArray() public {
        // Arrange
        vm.prank(USER); // Next transaction will be from USER

        // Act
        fundMe.fund{value: SEND_VALUE}();
        // Assert
        assertEq(fundMe.getFunder(0), USER);
    }

    modifier funded() {
        vm.prank(USER); // Next transaction will be from USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawIsNotOwner() public funded {
        // Act
        vm.expectRevert(); // Expect next line to revert because USER is not the owner
        fundMe.withdraw();
        // Assert
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 balance = owner.balance;
        vm.prank(owner); // Next transaction will be from the owner
        // Act
        fundMe.withdraw();
        // Assert
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);
        assertEq(owner.balance, balance + SEND_VALUE);
    }

    function testWithdrawWithMultipleFunders() public funded {
        address owner = fundMe.getOwner();

        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;
        uint256 startingGas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.withdraw();
        uint256 gasUsed = (startingGas - gasleft()) * tx.gasprice;
        console.log("Gas Used: ", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundmeBalance = address(fundMe).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundmeBalance
        );

        assertEq(endingFundmeBalance, 0);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        address owner = fundMe.getOwner();

        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        // Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;
        uint256 startingGas = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.cheaperWithdraw();
        uint256 gasUsed = (startingGas - gasleft()) * tx.gasprice;
        console.log("Gas Used: ", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundmeBalance = address(fundMe).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundmeBalance
        );

        assertEq(endingFundmeBalance, 0);
    }
}
