pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";



template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var size = 2**n;
    signal hashes[2*size-1];
    var i = size-1, j = 0;
    while(i < 2*size-1)
    {
        hashes[i] <== leaves[j];
        i +=1; j+=1;
    }
    i = 2*size - 2; j =0;
    component hash[size-1];
    while(i > 0)
    {
        hash[j] = Poseidon(2);
        hash[j].inputs[0] <== hashes[i-1];
        hash[j].inputs[1] <== hashes[i];
        hash[j].out ==> hashes[(i-1)\2];
        i-=2;j++;
    }
    root <== hashes[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    var i = 0;
    signal temp1[n];
    signal temp2[n];
    component hash[n];
    component comp[n];
    signal interhash[n+1];
    interhash[0] <== leaf;
    for(i = 0; i < n; i++)
    {
        hash[i] = Poseidon(2);
        temp1[i] <== path_elements[i] * path_index[i];
        temp2[i] <== interhash[i] * path_index[i];
        //in[0] = path_elements[i] * path_index[i] + interhash * (1 - path_index[i])
        hash[i].inputs[0] <== temp1[i] + interhash[i] - temp2[i];
        //in[1] = path_elements[i] * (1 - path_index[i]) + interhash * path_index[i])
        hash[i].inputs[1] <== path_elements[i] - temp1[i] + temp2[i];
        hash[i].out ==> interhash[i+1];
    }
    root <== interhash[n];
}