pragma solidity ^0.5.4;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title LandRegistry
 * @dev A minimal, simple database mapping properties to their on-chain representation (`TokenizedProperty`).
 *
 * The purpose of this contract is not to be official or replace the existing (off-chain) land registry.
 * Its purpose is to map entries in the official registry to their on-chain representation.
 * This mapping / bridging process is enabled by our legal framework, which works in-sync with and relies on this database.
 *
 * `this.landRegistry` is the single source of truth for on-chain properties verified legitimate by blockimmo.
 * Any property not indexed in `this.landRegistry` is NOT verified legitimate by blockimmo.
 *
 * `TokenizedProperty` references `this` to only allow tokens of verified properties to be transferred.
 * Any (unmodified) `TokenizedProperty`'s tokens will be transferable if and only if it is indexed in `this.landRegistry` (otherwise locked).
 *
 * `LandRegistryProxy` enables `this` to be easily and reliably upgraded if absolutely necessary.
 * `LandRegistryProxy` and `this` are controlled by a centralized entity.
 * This centralization provides an extra layer of control / security until our contracts are time and battle tested.
 * We intend to work towards full decentralization in small, precise, confident steps by transferring ownership
 * of these contracts when appropriate and necessary.
 */
contract LandRegistry is Ownable {
  mapping(string => address) private landRegistry;

  event Tokenized(string eGrid, address indexed property);
  event Untokenized(string eGrid, address indexed property);

  /**
   * this function's abi should never change and always maintain backwards compatibility
   */
  function getProperty(string memory _eGrid) public view returns (address property) {
    property = landRegistry[_eGrid];
  }

  function tokenizeProperty(string memory _eGrid, address _property) public onlyOwner {
    require(bytes(_eGrid).length > 0, "eGrid must be non-empty string");
    require(_property != address(0), "property address must be non-null");
    require(landRegistry[_eGrid] == address(0), "property must not already exist in land registry");

    landRegistry[_eGrid] = _property;
    emit Tokenized(_eGrid, _property);
  }

  function untokenizeProperty(string memory _eGrid) public onlyOwner {
    address property = getProperty(_eGrid);
    require(property != address(0), "property must exist in land registry");

    landRegistry[_eGrid] = address(0);
    emit Untokenized(_eGrid, property);
  }
}
