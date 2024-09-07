//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "../contracts/CheddarMinter.sol";
import "./DeployHelpers.s.sol";


contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);
    string _name = "ChedderToken";
    string _symbol = "CHED";
    uint256 _dailyQuota = 1000; // Max tokens mintable per day
    uint256 _userQuota = 100; // Max tokens mintable per user per day
    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);

        CheddarMinter cheddarMinter = new CheddarMinter(
            _name,
            _symbol,
            _dailyQuota,
            _userQuota
        );
        console.logString(
            string.concat(
                "CheddarMinter deployed at: ",
                vm.toString(address(cheddarMinter))
            )
        );

        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
