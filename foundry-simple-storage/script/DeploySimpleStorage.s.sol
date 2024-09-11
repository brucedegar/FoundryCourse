// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); // this command only working on Foundry
        // vm is a variable from forge-std/Script.sol
        // To inform that all the fowllowing transactions should send to RPC

        SimpleStorage simpleStorage = new SimpleStorage();

        vm.stopBroadcast(); // this command only working on Foundry

        return simpleStorage;

        // forge script script/DeploySimpleStorage.s.sol => auto deploy to Anvil
        // forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 => deploy to local RPC
        // forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        // => deploy to local RPC and broadcast the transaction
    }
}
