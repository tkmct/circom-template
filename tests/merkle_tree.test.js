const chai = require("chai");
const path = require("path");
const circomlib = require("circomlibjs");
const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

const buildMimcSponge = circomlib.buildMimcSponge;

describe("test merkle inclusion", function () {
  this.timeout(100000);

  let mimc;
  let F;
  before(async () => {
    mimc = await buildMimcSponge();
    F = mimc.F;
  });

  function calcHash(v) {
    return F.toObject(mimc.multiHash(typeof v === "number" ? [v] : v));
  }

  it("Checking the compilation of a circuit generating wasm", async () => {
    const node = 1;
    const leaf1 = 2;
    const leaf2 = calcHash([3, 4]);
    const proofs = [leaf1, leaf2];
    const merklePath = [0, 0];
    const root = calcHash([calcHash([node, leaf1]), leaf2]);

    const p = path.join(__dirname, "..", "circuits", "merkle_tree.circom");
    const circuit = await wasm_tester(p);

    const inputs = {
      root: root,
      merklePath: merklePath,
      merkleProofs: proofs,
      node: node,
    };

    const w = await circuit.calculateWitness(inputs);

    await circuit.checkConstraints(w);
    await circuit.assertOut(w, { result: 0 });
  });
});
