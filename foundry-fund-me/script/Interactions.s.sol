// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {

    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address _mostRecentAddress) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        fundFundMe(mostRecentlyDeployedFundMe);
    }
}

contract WithdrawFundMe is Script {
     function withdrawFundMe(address _mostRecentAddress) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentlyDeployedFundMe);
    }
}