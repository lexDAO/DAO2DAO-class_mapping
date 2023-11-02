// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {MolochV3EligibilityAdaptor} from "../src/adaptors/MolochV3EligibilityAdaptor.sol";

import {BaseDeployer} from "./BaseDeployer.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

contract DeployMolochV3EligibilityAdaptor is BaseDeployer {
    using stdJson for string;

    MolochV3EligibilityAdaptor public molochV3EligibilityAdaptor;

    function deploy() internal override returns (address) {
        vm.startBroadcast(deployerPrivateKey);

        molochV3EligibilityAdaptor = new MolochV3EligibilityAdaptor();

        vm.stopBroadcast();

        return address(molochV3EligibilityAdaptor);
    }
}
