// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CharacterSheetsFactory} from "../src/CharacterSheetsFactory.sol";

import {BaseDeployer} from "./BaseDeployer.sol";
import {BaseFactoryExecutor} from "./BaseExecutor.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

contract CharacterSheetsFactory is BaseDeployer {
    using stdJson for string;

    address public erc6551Registry;
    address public erc6551AccountImplementation;
    address public characterSheetsImplementation;
    address public experienceAndItemsImplementation;
    address public classesImplementation;

    CharacterSheetsFactory public characterSheetsFactory;

    function loadBaseAddresses(string memory json, string memory targetEnv) internal override {
        erc6551Registry = json.readAddress(string(abi.encodePacked(".", targetEnv, ".Erc6551Registry")));
        erc6551AccountImplementation = json.readAddress(string(abi.encodePacked(".", targetEnv, ".CharacterAccount")));
        characterSheetsImplementation =
            json.readAddress(string(abi.encodePacked(".", targetEnv, ".CharacterSheetsImplementation")));
        experienceAndItemsImplementation =
            json.readAddress(string(abi.encodePacked(".", targetEnv, ".ExperienceAndItemsImplementation")));
        classesImplementation = json.readAddress(string(abi.encodePacked(".", targetEnv, ".ClassesImplementation")));
    }

    function deploy() internal override returns (address) {
        require(erc6551AccountImplementation != address(0), "unknown erc6551AccountImplementation");
        require(erc6551Registry != address(0), "unknown erc6551Registry");
        require(characterSheetsImplementation != address(0), "unknown characterSheetsImplementation");
        require(experienceAndItemsImplementation != address(0), "unknown experienceAndItemsImplementation");
        require(classesImplementation != address(0), "unknown classesImplementation");

        vm.startBroadcast(deployerPrivateKey);

        characterSheetsFactory = new CharacterSheetsFactory();

        characterSheetsFactory.initialize();
        characterSheetsFactory.updateCharacterSheetsImplementation(characterSheetsImplementation);
        characterSheetsFactory.updateExperienceAndItemsImplementation(experienceAndItemsImplementation);
        characterSheetsFactory.updateERC6551Registry(erc6551Registry);
        characterSheetsFactory.updateERC6551AccountImplementation(erc6551AccountImplementation);
        characterSheetsFactory.updateClassesImplementation(classesImplementation);

        vm.stopBroadcast();

        return address(characterSheetsFactory);
    }
}

contract Create is BaseFactoryExecutor {
    using stdJson for string;

    address[] public dungeonMasters;
    address public dao;
    bytes public encodedNames;
    address public characterSheets;
    string public characterSheetsBaseUri;
    string public experienceBaseUri;
    string public classesBaseUri;
    address public characterSheetsAddress;
    address public experienceAndItems;
    address public classes;
    bytes public encodedData;
    CharacterSheetsFactory public factory;

    function loadBaseData(string memory json, string memory targetEnv) internal override {
        dao = json.readAddress(string(abi.encodePacked(".", targetEnv, ".Dao")));
        characterSheets = json.readAddress(string(abi.encodePacked(".", targetEnv, ".CharacterSheetsFactory")));
        dungeonMasters = json.readAddressArray(string(abi.encodePacked(".", targetEnv, ".DungeonMasters")));
        characterSheetsBaseUri = json.readString(string(abi.encodePacked(".", targetEnv, ".CharacterSheetsBaseUri")));
        experienceBaseUri = json.readString(string(abi.encodePacked(".", targetEnv, ".ExperienceBaseUri")));
        classesBaseUri = json.readString(string(abi.encodePacked(".", targetEnv, ".ClassesBaseUri")));
        factory = CharacterSheetsFactory(characterSheets);
        encodedData = abi.encode(characterSheetsBaseUri, experienceBaseUri, classesBaseUri);
    }

    function create() internal override returns (address, address, address) {
        vm.startBroadcast(deployerPrivateKey);
        (characterSheetsAddress, experienceAndItems, classes) = factory.create(dungeonMasters, dao, encodedData);
        vm.stopBroadcast();
        return (characterSheetsAddress, experienceAndItems, classes);
    }
}
