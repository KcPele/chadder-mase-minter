// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/CheddarToken.sol";

contract CheddarTokenTest is Test {
    CheddarToken public cheddarToken;
    address public owner;
    address public newMinter;
    address public user;

    event MinterChanged(address indexed newMinter);
    event ActiveStatusChanged(bool active);

    function setUp() public {
        owner = address(this);
        newMinter = address(0x1);
        user = address(0x2);
        cheddarToken = new CheddarToken("Cheddar", "CHDR");
    }

    function testInitialState() public {
        assertEq(cheddarToken.minter(), owner);
        assertTrue(cheddarToken.active());
    }

    function testAdminChangeMinter() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit MinterChanged(newMinter);
        cheddarToken.adminChangeMinter(newMinter);

        assertEq(cheddarToken.minter(), newMinter);
    }

    function testToggleActive() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit ActiveStatusChanged(false);
        cheddarToken.toggleActive();

        assertFalse(cheddarToken.active());

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit ActiveStatusChanged(true);
        cheddarToken.toggleActive();

        assertTrue(cheddarToken.active());
    }

    function testMintByMinter() public {
        uint256 mintAmount = 100 * 1e18;

        vm.prank(owner);
        cheddarToken.mint(user, mintAmount);

        assertEq(cheddarToken.balanceOf(user), mintAmount);
    }

    function testFailMintByNonMinter() public {
        uint256 mintAmount = 100 * 1e18;

        vm.prank(user);
        cheddarToken.mint(user, mintAmount); // Should fail
    }

    function testFailMintWhenInactive() public {
        uint256 mintAmount = 100 * 1e18;

        vm.prank(owner);
        cheddarToken.toggleActive();

        vm.prank(owner);
        cheddarToken.mint(user, mintAmount); // Should fail
    }
}