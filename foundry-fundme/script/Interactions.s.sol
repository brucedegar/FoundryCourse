// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// Fund
// Withdraw

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        //console.log("Most recently deployed: ", mostRecentlyDeployed);
        vm.startBroadcast();
        FundMe fundMe = FundMe(mostRecentlyDeployed);
        console.log("FundMe address: ", address(fundMe));
        console.log("This address: ", address(this));
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(contractAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function withdrawFundMe(address mostRecentlyDeployed) public {
        //console.log("Most recently deployed: ", mostRecentlyDeployed);
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentlyDeployed));
        fundMe.withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(contractAddress);
        vm.stopBroadcast();
    }
}
