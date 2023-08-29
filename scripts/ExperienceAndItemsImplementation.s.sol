// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ExperienceAndItemsImplementation} from "../src/implementations/ExperienceAndItemsImplementation.sol";
import {BaseExecutor} from "./BaseExecutor.sol";
import {BaseDeployer} from "./BaseDeployer.sol";
import "../src/lib/Structs.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

contract DeployExperienceAndItemsImplementation is BaseDeployer {
    using stdJson for string;

    ExperienceAndItemsImplementation public experienceAndItemsImplementation;

    function deploy() internal override returns (address) {
        vm.startBroadcast(deployerPrivateKey);

        experienceAndItemsImplementation = new ExperienceAndItemsImplementation();

        vm.stopBroadcast();

        return address(experienceAndItemsImplementation);
    }
}

struct InterItem {
    /// @dev this item's image/metadata uri
    string cid;
    /// @dev  claimable: if bytes32(0) then  items are claimable by anyone, otherwise upload a merkle root
    /// of all addresses allowed to claim.  if not claimable at all use any random bytes32(n) besides bytes32(0)
    /// so all merkle proofs will fail.
    uint256[][] claimable;
    /// @dev this is the array of classes required to transfer this item
    uint256[] classRequirements;
    /// @dev an array of arrays with length of 2. containing the required itemId and the amount required
    /// eg. [[itemId, amount], [itemId, amount]]
    uint256[][] itemRequirements;
    /// @dev the name of this item
    string name;
    /// @dev is this item soulbound or not
    uint256 soulbound;
    /// @dev the number of this item that have been given out or claimed
    uint256 supplied;
    /// @dev the number of this item to be created.
    uint256 supply;
    /// @dev erc1155 token id
    bytes tokenId;
}

contract ExecuteExperienceAndItemsImplementation is BaseExecutor {
    using stdJson for string;

    InterItem public newItem;

    bytes public intermediaryBytes;

    ExperienceAndItemsImplementation public experience;
    address public experienceAddress;
    string public itemName;
    uint256 public supply;
    string public uri;
    bool public soulbound;
    uint256[][] public itemRequirements;
    uint256[] public classRequirements;
    uint256[][] public merkle;

    function loadBaseData(string memory json, string memory targetEnv) internal override {
        experienceAddress = json.readAddress(string(abi.encodePacked(".", targetEnv, ".CreatedExperienceAndItems")));
        experience = ExperienceAndItemsImplementation(experienceAddress);
        uri = json.readString(string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].cid")));
        soulbound = json.readBool(string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].soulbound")));
        supply = json.readUint(string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].supply")));
        itemName = json.readString(string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].name")));
        classRequirements = json.readUintArray(
            string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].requirements.classRequirements"))
        );

        bytes memory intermediaryBytesItem = json.parseRaw(
            string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].requirements.itemRequirements"))
        );
        (itemRequirements) = abi.decode(intermediaryBytesItem, (uint256[][]));
        bytes memory merkleData =
            json.parseRaw(string(abi.encodePacked(".", targetEnv, ".Items[", arrIndex, "].requirements.claimable")));
        (merkle) = abi.decode(merkleData, (uint256[][]));
    }

    function execute() internal override {
        bytes memory encodedData = abi.encode(
            newItem.name,
            newItem.supply,
            newItem.itemRequirements,
            newItem.classRequirements,
            newItem.soulbound,
            _createMerkleRoot(),
            newItem.cid
        );

        vm.broadcast(deployerPrivateKey);
        experience.createItemType(encodedData);
    }

    function _createMerkleRoot() internal pure returns (bytes32) {
        return bytes32(0);
    }
}
