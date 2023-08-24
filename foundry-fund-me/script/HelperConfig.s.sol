// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INTIAL_PRICE = 2000e8;

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory sepoliaConfigs) {
        sepoliaConfigs = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory anvilConfigs) {

        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        
        vm.startBroadcast();
        
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INTIAL_PRICE);

        vm.stopBroadcast();

        anvilConfigs = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
    }
}