// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

contract SmallProxy is Proxy {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function setImplementation(address newImplementation) public {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _implementation() internal view override returns (address implementationAddress) {
        assembly {
            implementationAddress := sload(_IMPLEMENTATION_SLOT)
        }
    }

    function getDataToTransact(uint256 numberToUpdate) public pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", numberToUpdate);
    }

    function readStorage() public view returns (uint256 valueAtStorageSlotZero) {
        assembly {
            valueAtStorageSlotZero := sload(0x00)
        }
    }
}

// When calling SmallProxy contract we want to delegatecall to the ImplementationA contract and store the result in SmallProxy's storage slot.

contract ImplementationA {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue;
    }

    /**
     * The below functions would never get called as the Proxy Contract's function will keep
     * getting matched instead. Require the TransparentProxy pattern.
     * The following functions would lead to a function selector clash.
     *
     * function setImplementation(address newImplementation) public {}
     *
     * OR
     *
     * A function which has the same selector (first 4 bytes of the keccak256 (hashed) function signature).
     */
}

contract ImplementationB {
    uint256 public value;

    function setValue(uint256 newValue) public returns (uint256) {
        value = newValue + 48;
        return newValue;
    }
}
