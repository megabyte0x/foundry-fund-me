// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory sepoliaConfigs) {
        sepoliaConfigs = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getAnvilETHConfig() public pure returns (NetworkConfig memory anvilConfigs) {
        return NetworkConfig({
            priceFeed: 0x9326BFA02ADD2366b30bacB125260Af641031331
        });
    }
}