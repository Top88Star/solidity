//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); //cheatcode
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //cheatcode sets fake user some money
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceVersionIsOkay() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function fundFails() public {
       vm.expectRevert(); //cheatcode
       fundMe.fund();
    }

    function testFundUpdates() public {
       vm.prank(USER); //cheatcode

       fundMe.fund{value: SEND_VALUE}();
       uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
       assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(USER); //cheatcode
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); 
        assertEq(funder, USER);
    }

    modifier funded() { //saves the code inside so we don't repeat it / have to be called in the function
        vm.prank(USER); //cheatcode
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); //cheatcode
        vm.prank(USER); //cheatcode
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBallance = fundMe.getOwner().balance;
        uint256 startingFundMeBallance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner()); //cheatcode
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBallance = fundMe.getOwner().balance;
        uint256 endingFundMeBallance = address(fundMe).balance;

        assertEq(endingFundMeBallance, 0);
        assertEq(startingFundMeBallance + startingOwnerBallance, endingOwnerBallance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
       uint160 numberOfFunders = 10;
       uint160 startingFunderIndex = 2;

       for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
           hoax(address(i), SEND_VALUE);
           fundMe.fund{value: SEND_VALUE}();
       }

        uint256 startingOwnerBallance = fundMe.getOwner().balance;
        uint256 startingFundMeBallance = address(fundMe).balance;

        //Act
        // uint256 gasStart = gasleft(); //cheatcode
        // vm.txGasPrice(GAS_PRICE); //cheatcode
        vm.prank(fundMe.getOwner()); //cheatcode
        fundMe.withdraw();
        // uint256 gasEnd = gasleft(); //cheatcode
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //cheatcode
        // console.log(gasUsed); //cheatcode
        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBallance + startingFundMeBallance == fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        //Arrange
       uint160 numberOfFunders = 10;
       uint160 startingFunderIndex = 2;

       for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
           hoax(address(i), SEND_VALUE);
           fundMe.fund{value: SEND_VALUE}();
       }

        uint256 startingOwnerBallance = fundMe.getOwner().balance;
        uint256 startingFundMeBallance = address(fundMe).balance;

        //Act
        // uint256 gasStart = gasleft(); //cheatcode
        // vm.txGasPrice(GAS_PRICE); //cheatcode
        vm.prank(fundMe.getOwner()); //cheatcode
        fundMe.cheaperWithdraw();
        // uint256 gasEnd = gasleft(); //cheatcode
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //cheatcode
        // console.log(gasUsed); //cheatcode
        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBallance + startingFundMeBallance == fundMe.getOwner().balance);
    }
}
