// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/CheddarMinter.sol";

contract CheddarMinterTest is Test {
    CheddarMinter public cheddarMinter;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    address public referral = address(4);

    function setUp() public {
        vm.prank(owner);
        cheddarMinter = new CheddarMinter(
            "Cheddar Token",
            "CHED",
            1000 ether,
            500 ether
        );
    }

    function testMintTokensWithoutReferral() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, 100 ether, address(0));

        assertEq(cheddarMinter.balanceOf(user1), 100 ether);
    }

    function testMintTokensWithReferral() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, 100 ether, referral);

        // 5% referral bonus should be minted
        assertEq(cheddarMinter.balanceOf(user1), 95 ether); // User gets 95%
        assertEq(cheddarMinter.balanceOf(referral), 5 ether); // Referral gets 5%
    }

    function testExceedUserQuota() public {
        vm.prank(owner); // Ensure the caller is the minter
        cheddarMinter.mint(user1, 500 ether, address(0));

        // This next mint should exceed the user quota
        vm.expectRevert("User mint quota exceeded");
        vm.prank(owner); // Ensure it's still the minter
        cheddarMinter.mint(user1, 10 ether, address(0));
    }

    function testExceedDailyQuota() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, 500 ether, address(0));
        cheddarMinter.mint(user2, 500 ether, address(0));

        // This next mint should exceed the daily quota
        vm.expectRevert("Daily mint quota exceeded");
        cheddarMinter.mint(user1, 10 ether, address(0));
    }

    function testStateUpdateAfterMinting() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, 100 ether, address(0));

        // Check daily mints update
        (, , , , uint256 dailyMints) = cheddarMinter.getConfig();
        assertEq(dailyMints, 100 ether);

        // Check user-specific mint data
        (uint256 day, uint256 minted) = cheddarMinter.getUserMintData(user1);
        assertEq(minted, 100 ether);
    }
}
