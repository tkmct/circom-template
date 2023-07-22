pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

template MerkleTree (n) {
  signal input root;
  signal input merklePath[n];
  signal input merkleProofs[n];

  signal ls[2*n];
  signal rs[2*n];

  // leaf node whose inclusion will be proved
  signal input node;
  signal output result;

  component hasher[n];

  var cur = node;
  signal leaves[n];
  for (var i = 0; i < n; i++) {
    hasher[i] = MiMCSponge(2, 220, 1);
    ls[2*i] <-- cur * (1 - merklePath[i]);
    ls[2*i+1] <-- merkleProofs[i] * merklePath[i];

    rs[2*i] <-- cur * merklePath[i];
    rs[2*i+1] <-- merkleProofs[i] * (1-merklePath[i]);

    hasher[i].ins[0] <== ls[2*i] + ls[2*i+1];
    hasher[i].ins[1] <== rs[2*i] + rs[2*i+1];

    hasher[i].k <== 0;
    leaves[i] <== hasher[i].outs[0];
    cur = hasher[i].outs[0];
  }

  // last leaf should equal to root
  leaves[n-1] === root;
  result <== leaves[n-1] - root;
}

component main {public [root, merklePath, merkleProofs]} = MerkleTree(2);
