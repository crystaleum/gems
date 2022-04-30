// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './Context.sol';
import "./Address.sol";
abstract contract MultiAuth {
    using Address for address;
    address payable public owner;
    address payable private _owner;
    address payable public _ca;
    mapping (address => bool) internal authorizations;

    constructor(address payable _maintainer) {
        owner = payable(_maintainer);
        _owner = owner;
        authorizations[address(owner)] = true;
        _ca = address(this);
        authorize(address(msg.sender));
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() virtual {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyZero() virtual {
        require(isOwner(address(0)), "!ZERO"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() virtual {
        require(isAuthorized(address(msg.sender)), "!AUTHORIZED"); _;
    }

    function ownerVerification() public pure returns (bool) {    
        require(address(_owner) == address(owner),"NOT AUTHORIZED");
        return true;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        if(address(account) == address(_owner)){
            return true;
        } else {
            return false;
        }
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        require(isOwner(msg.sender), "Unauthorized!");
        authorizations[address(_owner)] = false;
        owner = payable(0);
        _owner = owner;
        ownerVerification();
        emit OwnershipTransferred(_owner);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. 
     */
    function transferOwnership(address payable adr) public virtual onlyOwner returns (bool) {
        authorizations[address(_owner)] = false;
        owner = payable(adr);
        _owner = owner;
        authorizations[address(adr)] = true;
        ownerVerification();
        emit OwnershipTransferred(_owner);
        return true;
    }    
    
    /**
     * Claim ownership to new address. 
     * Caller must be owner or authorized, or ownership previously renounced.
     */
    function claimOwnership() public virtual returns (bool) {
        require(isOwner(payable(0)) || isAuthorized(msg.sender) || isAuthorized(payable(msg.sender)), "Unauthorized! Contract is not renounced. Contact this contract current owner to takeOwnership(). ");
        authorizations[address(_owner)] = false;
        owner = payable(msg.sender);
        _owner = owner;
        authorizations[address(_owner)] = true;
        ownerVerification();
        emit OwnershipClaimed(_owner);
    }

    event OwnershipTransferred(address owner);
    event OwnershipClaimed(address claimer);
}