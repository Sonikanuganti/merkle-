// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract MerkleTreeWhiteListCounter {
    bytes32 public rootHash;
    uint256 public count;
    address public token;
    uint256 public dropAmount;

    mapping (address => uint256) public addressesClaimed;
    
    constructor(bytes32 _rootHash, address _token){
        rootHash = _rootHash;
        token = _token;
    }

    modifier isWhiteListedAddress(bytes32[] calldata proof){
       require(isValidProof(proof,keccak256(abi.encodePacked(msg.sender))),"Not WhiteListed Address");
        _;
    }

    function isValidProof(bytes32[] calldata proof, bytes32 leaf) private view returns (bool) {
        return MerkleProof.verify(proof, rootHash, leaf);
    }

 function claim(bytes32[] calldata merkleProof)
        external
    {
        require(addressesClaimed[msg.sender] ==0,'Drop Tokens Already Claimed');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(msg.sender));

        require(isValidProof(merkleProof, node),'Not Eligible for Drop');

        addressesClaimed[msg.sender] == 1;
        // Mark it claimed and send the token.
        require(IERC20(token).transfer(msg.sender,dropAmount),'Transfer Failed');

        // emit Claimed(msg.sender,dropAmount);
    }


    function whiteListIncrement(bytes32[] calldata proof)  isWhiteListedAddress(proof) external  {
        count++;
    }

    
}
