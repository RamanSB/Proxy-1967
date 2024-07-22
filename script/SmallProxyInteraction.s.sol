// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {SmallProxy, ImplementationA, ImplementationB} from "../src/SmallProxy.sol";
import {Script, console} from "forge-std/Script.sol";

contract Interaction is Script {
    SmallProxy smallProxy;
    ImplementationA implContract;
    ImplementationB upgradedImplContract;

    /**
     * @notice Post execution of this script leverage `cast storage <proxyAddress> _IMPLEMENTATION_SLOT/0 --rpc-url <anvil>"
     *
     *  Alternatively invoke:
     *  `cast call <proxyAddress> "readStorage()" --rpc-url http://127.0.0.1:8545 `
     */
    function run() external {
        vm.startBroadcast();
        implContract = new ImplementationA();
        smallProxy = new SmallProxy();
        upgradedImplContract = new ImplementationB();
        smallProxy.setImplementation(address(implContract));
        bytes memory executionData = smallProxy.getDataToTransact(69);
        console.logBytes(executionData);
        (bool success, bytes memory data) = address(smallProxy).call{value: 0}(executionData);
        console.log("Call successful: ", success);
        console.logBytes(data);
        smallProxy.setImplementation(address(upgradedImplContract)); // Expect the Upgraded Event to be emitted.
        executionData = smallProxy.getDataToTransact(52);
        (success, data) = address(smallProxy).call{value: 0}(executionData);
        console.log("Call successful (uses new upgradedImpl): ", success);
        console.logBytes(data); // Should be 52
        uint256 newValueAtProxyStorage = smallProxy.readStorage();
        console.log(newValueAtProxyStorage); // should be 100.
        vm.stopBroadcast();
    }
}
