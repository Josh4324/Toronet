const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("eco", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user1, user2, user3, user4, user5] =
      await ethers.getSigners();

    const ECO = await ethers.getContractFactory("ECO4Reward");
    const eco = await ECO.deploy();

    return { eco, owner, user1, user2, user3, user4, user5 };
  }

  describe("eco", function () {
    it("Test 1", async function () {
      const { eco, user1, user2, user3, user4, owner } = await loadFixture(
        deploy
      );

      function sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
      }

      await eco.donateOrFund({ value: ethers.parseEther("1000") });

      await eco.addAdmin(user1.address);

      await eco.connect(user2).registerAction("env", "desc", "proof");

      await eco.connect(user1).confirmAction(0, 5);

      await eco.connect(user3).registerWaste(100);

      await eco.connect(user1).confirmWaste(0, 5);

      await eco.registerTrees(5);

      await eco.connect(user1).confirmTress(0, 5);

      console.log("total", await ethers.provider.getBalance(eco.target));

      console.log(await eco.getUserData(owner.address));

      await eco.getPaid(1);

      console.log(await eco.getUserData(owner.address));

      //console.log(await eco.getContractData());

      console.log(await eco.getUserList());
    });
  });
});
