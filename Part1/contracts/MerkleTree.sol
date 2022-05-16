//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract
import "hardhat/console.sol";

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint256 i;
        for(i = 0; i < 15; i++)
        {
            hashes.push(0);
        }
        //i = 8
        i = 0;
        while(i != 14)
        {
            uint256 par_index = 8 + (i/2);
            uint256[2] memory input;
            input[0] = hashes[i];
            input[1] = hashes[i+1];
            hashes[par_index] = PoseidonT3.poseidon(input);
            i += 2;
        }
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint tempi = index;
        while(tempi != 14)
        {
            uint[2] memory input;
            if(tempi %2 == 0)
            {
                input[0] = hashes[tempi];
                input[1] = hashes[tempi + 1];
            }
            else
            {
                input[0] = hashes[tempi - 1];
                input[1] = hashes[tempi];
            }
            tempi = 8 + (tempi/2);
            hashes[tempi] = PoseidonT3.poseidon(input);
        }
        root = hashes[tempi];
        index++;
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool b1 = Verifier.verifyProof(a, b, c, input);
        bool b2 = (input[0] == root);
        return b1 && b2;
    }
}
