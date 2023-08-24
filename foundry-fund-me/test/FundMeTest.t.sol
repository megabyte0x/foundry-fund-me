// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address JIM = makeAddr("JIM");

    uint256 constant JIMS_STARTING_BALANCE = 100e18;
    uint256 constant SEND_VALUE = 10e18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        deal(JIM, JIMS_STARTING_BALANCE);
    }

    function testMinimumDollarIsFive()  public {
        assertEq(fundMe.getMinimumUSD(),5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedFunctionIsAccurate() public {
        assertEq(fundMe.getVersion(),4);
    }

    function testFundWithoutEnoughETH() public {
        vm.expectRevert();
        
        fundMe.fund();
    }

    function testFundsUpdatesInTheVariable() public {
        vm.prank(JIM);

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(JIM);
        assertEq(amountFunded, 10e18);
    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(JIM);

        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, JIM);
    }

    modifier funded() {
        vm.prank(JIM);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdrawETH() public funded {
        vm.expectRevert();
        vm.prank(JIM);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        assertEq(fundMeEndingBalance, 0);
    }

    function testWithdrawWithMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundingIndex = 1;

        for (uint160 i = startingFundingIndex; i< numberOfFunders; i++) {
            hoax(address(i), JIMS_STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // ASSERT

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        assertEq(fundMeEndingBalance, 0);
    }

        function testWithdrawWithMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFundingIndex = 1;

        for (uint160 i = startingFundingIndex; i< numberOfFunders; i++) {
            hoax(address(i), JIMS_STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // ACT
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // ASSERT

        uint256 ownerEndingBalance = fundMe.getOwner().balance;
        uint256 fundMeEndingBalance = address(fundMe).balance;
        assertEq(ownerEndingBalance, ownerStartingBalance + fundMeStartingBalance);
        assertEq(fundMeEndingBalance, 0);
    }
}
