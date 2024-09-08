// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/CheddarMinter.sol";

contract CheddarMinterTest is Test {
    CheddarMinter public cheddarMinter;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant DAILY_QUOTA = 1000 * 1e18;
    uint256 public constant USER_QUOTA = 100 * 1e18;

    event TokensMinted(
        address indexed recipient,
        uint256 amount,
        address indexed referral,
        uint256 referralAmount
    );

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        cheddarMinter = new CheddarMinter(
            "Cheddar",
            "CHDR",
            DAILY_QUOTA,
            USER_QUOTA
        );
    }

    // function testInitialState() public {
    //     (
    //         address minter,
    //         bool active,
    //         uint256 dailyQuota,
    //         uint256 userQuota,
    //         uint256 dailyMints
    //     ) = cheddarMinter.getConfig();
    //     assertEq(minter, owner);
    //     assertTrue(active);
    //     assertEq(dailyQuota, DAILY_QUOTA);
    //     assertEq(userQuota, USER_QUOTA);
    //     assertEq(dailyMints, 0);
    // }

    // function testMint() public {
    //     uint256 mintAmount = 50 * 1e18;
    //     vm.prank(owner);
    //     vm.expectEmit(true, true, true, true);
    //     emit TokensMinted(user1, mintAmount, address(0), 0);
    //     cheddarMinter.mint(user1, mintAmount, address(0));

    //     assertEq(cheddarMinter.balanceOf(user1), mintAmount);
    // }

    function testMintWithReferral() public {
        uint256 mintAmount = 100 * 1e18;
        uint256 referralAmount = mintAmount / 20; // 5%
        uint256 userAmount = mintAmount - referralAmount;

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit TokensMinted(user1, userAmount, user2, referralAmount);
        cheddarMinter.mint(user1, mintAmount, user2);

        assertEq(cheddarMinter.balanceOf(user1), userAmount);
        assertEq(cheddarMinter.balanceOf(user2), referralAmount);
    }

    function testFailMintExceedDailyQuota() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, DAILY_QUOTA, address(0));

        vm.prank(owner);
        cheddarMinter.mint(user2, 1, address(0)); // Should fail
    }

    function testFailMintExceedUserQuota() public {
        vm.prank(owner);
        cheddarMinter.mint(user1, USER_QUOTA, address(0));

        vm.prank(owner);
        cheddarMinter.mint(user1, 1, address(0)); // Should fail
    }

    // function testMintResetDailyQuota() public {
    //     vm.prank(owner);
    //     cheddarMinter.mint(user1, DAILY_QUOTA, address(0));

    //     // Move to the next day
    //     vm.warp(block.timestamp + 1 days);

    //     vm.prank(owner);
    //     cheddarMinter.mint(user2, DAILY_QUOTA, address(0)); // Should succeed
    // }

    function testGetUserMintData() public {
        uint256 mintAmount = 50 * 1e18;
        vm.prank(owner);
        cheddarMinter.mint(user1, mintAmount, address(0));

        (uint256 day, uint256 minted) = cheddarMinter.getUserMintData(user1);
        assertEq(day, block.timestamp / 1 days);
        assertEq(minted, mintAmount);
    }

    function testFailMintNonMinter() public {
        vm.prank(user1);
        cheddarMinter.mint(user2, 100, address(0)); // Should fail
    }

    function testFailMintInactive() public {
        vm.prank(owner);
        cheddarMinter.toggleActive();

        vm.prank(owner);
        cheddarMinter.mint(user1, 100, address(0)); // Should fail
    }

    function testMinGasRequirement() public {
        uint256 mintAmount = 50 * 1e18;
        vm.prank(owner);
        vm.expectRevert("Insufficient gas for minting");
        cheddarMinter.mint{gas: 29999}(user1, mintAmount, address(0)); // Should fail
    }
}
