// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// Remember even if it’s a script it still works like a smart contract, but is never deployed, so just like any other smart contract written in Solidity the pragma version has to be specified.
contract DeployFundMe is Script {
    // By default, scripts are executed by calling the function named run, our entrypoint.
    function run() external returns (FundMe) {
        // The reason we put this line before the startBroadcast is because we want to
        // deploy this contract to the real chain
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
