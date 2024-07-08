pragma solidity 0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RewardCTF {

    IERC20 immutable token;
    address immutable admin;

    mapping(bytes => bool) private consumed_signatures;

    constructor(address _admin, address token_) {
        token = IERC20(token_);
        admin = _admin;
    }

    function claim(
        uint256 amount,
        uint256 expiry,
        bytes memory signature
    ) external {
        require(expiry > block.timestamp, "INVALID EXPIRY");
        require(!consumed_signatures[signature], "CONSUMED SIGNATURE");

        consumed_signatures[signature] = true;

        bytes32 _messageHash = keccak256(
            abi.encode(msg.sender, amount, expiry)
        );
        _messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );

        (bytes32 _r, bytes32 _s, uint8 _v) = _splitSignature(signature);
        address _signer = ecrecover(_messageHash, _v, _r, _s);
        require(
            _signer == admin,
            "INVALID SIGNER"
        );

        token.transfer(msg.sender, amount);
    }


    function _splitSignature(bytes memory sig_)
        public
        pure
        returns (bytes32 _r, bytes32 _s, uint8 _v)
    {
        require(sig_.length == 65, "invalid length");

        assembly {
            _r := mload(add(sig_, 32))
            _s := mload(add(sig_, 64))
            _v := byte(0, mload(add(sig_, 96)))
        }
    }
}