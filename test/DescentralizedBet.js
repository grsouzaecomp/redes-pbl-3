const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DescentralizedBet", function () {
  async function deployBetFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const betContract = await ethers.deployContract("DescentralizedBet");
    return { betContract, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { betContract, owner } = await loadFixture(deployBetFixture);
      expect(await betContract.owner()).to.equal(owner.address);
    });
  });

  describe("Event Management", function () {
    it("Should allow owner to create events", async function () {
      const { betContract } = await loadFixture(deployBetFixture);

      await betContract.createEvent("Match 1", 200);
      const event = await betContract.bettingEvents(1);

      expect(event.name).to.equal("Match 1");
      expect(event.odds).to.equal(200);
      expect(event.resolved).to.equal(false);
    });

    it("Should prevent non-owner from creating events", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await expect(
        betContract.connect(addr1).createEvent("Match 2", 150)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("Placing Bets", function () {
    it("Should allow valid bets", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await betContract.createEvent("Match 1", 200);

      await betContract.connect(addr1).placeBet(1, 1, { value: ethers.parseEther("1") });

      const bets = await betContract.getEventBets(1);
      expect(bets.length).to.equal(1);
      expect(bets[0].bettor).to.equal(addr1.address);
      expect(bets[0].amount).to.equal(ethers.parseEther("1"));
    });
  });

  describe("Resolving Events", function () {
    it("Should allow owner to resolve events and payout", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await betContract.createEvent("Match 1", 200);
      await betContract.connect(addr1).placeBet(1, 1, { value: ethers.parseEther("1") });

      await betContract.resolveEvent(1, 1);

      const event = await betContract.bettingEvents(1);
      expect(event.resolved).to.equal(true);
      expect(event.result).to.equal(1);

      const balance = await betContract.balances(addr1.address);
      expect(balance).to.equal(ethers.parseEther("3"));
    });

    it("Should revert if non-owner tries to resolve events", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await betContract.createEvent("Match 1", 200);
      await betContract.connect(addr1).placeBet(1, 1, { value: ethers.parseEther("1") });

      await expect(
        betContract.connect(addr1).resolveEvent(1, 1)
      ).to.be.revertedWith("Not authorized");
    });
  });

  describe("Withdrawals", function () {
    it("Should allow users to withdraw funds", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await betContract.createEvent("Match 1", 200);
      await betContract.connect(addr1).placeBet(1, 1, { value: ethers.parseEther("1") });
      await betContract.resolveEvent(1, 1);

      // Deposit Ether to ensure the contract has enough funds for withdrawals
      await betContract.deposit({ value: ethers.parseEther("3") });

      const initialBalance = BigInt(await ethers.provider.getBalance(addr1.address));

      // Execute the withdrawal transaction
      const tx = await betContract.connect(addr1).withdraw();
      console.log("User 1 executed the withdraw() function...");

      const receipt = await tx.wait(1);  // Wait for 1 block confirmation

      if (receipt) {
        const gasUsed = receipt.gasUsed;
        console.log(`Gas used in the transaction: ${gasUsed.toString()} units`);

        const effectiveGasPrice = tx.gasPrice || receipt.effectiveGasPrice; // Compatibility with older versions
        console.log(`Effective gas price: ${effectiveGasPrice.toString()} wei`);

        const gasCost = gasUsed * effectiveGasPrice;
        console.log(`Total gas cost: ${gasCost.toString()} wei`);

        const finalBalance = BigInt(await ethers.provider.getBalance(addr1.address));
        console.log(`Final balance of User 1: ${finalBalance.toString()} wei`);

        // Verifying the balance after withdrawal, considering the gas cost
        expect(finalBalance).to.equal(initialBalance + BigInt(ethers.parseEther("3")) - gasCost);
      } else {
        throw new Error("Transaction receipt not found");
      }
    });

    it("Should revert if no funds to withdraw", async function () {
      const { betContract, addr1 } = await loadFixture(deployBetFixture);

      await expect(
        betContract.connect(addr1).withdraw()
      ).to.be.revertedWith("No balance to withdraw.");
    });
  });
});