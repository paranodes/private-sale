pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract AirDrop is Ownable {

    IERC20 public token;

    constructor(address _token) public {
        token = IERC20(_token);
    }

    // ================= ONLY OWNER FUNCTIONS =================

    /**
    * @dev Allows the current owner to change the token to be airdropped.
    * @param _token The new token to airdrop.
    */
    function changeToken(address _token) onlyOwner public {
        token = IERC20(_token);
    }

    /**
    * @dev Proceed with the airdrop.
    * @param _recipients Array of all the addresses that will receive an airdrop.
    * @param _values Array of all the balances that will be sent to the corresponding address.
    */
    function airdrop(address[] _recipients, uint[] _values) onlyOwner public {
        require(_recipients.length == _values.length, "ADRP: Recipients and values must be the same length.");
        for (uint i = 0; i < _values.length; i++) {
            token.transfer(_recipients[i], _values[i]);
        }
    }

    /**
    * @dev Transfers the native tokens from the smart contract to the owner.
    */
    function withdraw() public payable onlyOwner {
      (bool os, ) = payable(owner()).call{value: address(this).balance}("");
      require(os);
    }

    /**
    * @dev Transfers the native tokens from the smart contract to the owner.
    */
    function withdrawNative() onlyOwner public {
      if (address(this).balance > 0) {
        owner.transfer(address(this).balance);
      }
    }

    /**
    * @dev Transfers the airdrop tokens from the smart contract to the owner.
    */
    function withdrawToken() onlyOwner public {
      if (token.balanceOf(address(this)) > 0) {
        token.transfer(
          owner,
          token.balanceOf(address(this))
        );
      }
    }

    /**
    * @dev Transfers any token from the smart contract to the owner.
    * @param _token The tokens to be transfered to the owner.
    */
    function withdrawToken(address _token) onlyOwner public {
      if (IERC20(_token).balanceOf(address(this)) > 0) {
        IERC20(_token).transfer(
          owner,
          IERC20(_token).balanceOf(address(this))
        );
      }
    }
}
