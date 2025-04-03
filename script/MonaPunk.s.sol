// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {MonaPunk} from "../src/MonaPunk.sol";

contract MonaPunkScript is Script {
    MonaPunk public monaPunk;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        monaPunk = new MonaPunk(deployerAddress);
        console.log("MonaPunk deployed to:", address(monaPunk));

        vm.stopBroadcast();
    }
}
