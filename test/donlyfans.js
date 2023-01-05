const { ethers } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("dOnlyFans main contract", function () {
  it("Should create a new Creator Profile and add it to list of creators", async function () {
    const dOnlyFans = await ethers.getContractFactory("dOnlyFans");

    const hardhatDOnlyFans = await dOnlyFans.deploy();

    await hardhatDOnlyFans.deployed();

    const createProfile = await hardhatDOnlyFans.createProfile(2);
    const receipt = await createProfile.wait();
    // console.log("Address of first CC: ");
    // console.log();
    // console.log(receipt.events[0].args.creatorContractAddress);
  });
});

describe("Creator contract", function () {
  async function deployCreatorContractFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const creator = await ethers.getContractFactory("Creator");

    const hardhatCreator = await creator.deploy(owner.address, 2);

    await hardhatCreator.deployed();

    const firstSubscription = await hardhatCreator.connect(addr1).subscribe({
      value: ethers.utils.parseEther("2.0"),
    });

    // Fixtures can return anything you consider useful for your tests
    return { creator, hardhatCreator, owner, addr1, addr2 };
  }
  it("Verify subscription", async function () {
    const { hardhatCreator, owner, addr1 } = await loadFixture(
      deployCreatorContractFixture
    );
    const [subs] = await hardhatCreator.getSubscribers();
    console.log(subs);
    console.log(addr1.address);
    expect(subs).to.equal(addr1.address);
  });

  it("Unsubscribing", async function () {
    const { hardhatCreator, owner, addr1, addr2 } = await loadFixture(
      deployCreatorContractFixture
    );
    const secondSubscription = await hardhatCreator.connect(addr2).subscribe({
      value: ethers.utils.parseEther("2.0"),
    });
    // const subs_intermediary = await hardhatCreator.getSubscribers();
    // console.log(subs_intermediary);
    const unsub = await hardhatCreator.connect(addr1).unsubscribe();

    const [sub1, sub2] = await hardhatCreator.getSubscribers();
    expect(sub2).to.equal(addr2.address);
    expect(sub1).to.equal("0x0000000000000000000000000000000000000000"); // this indicates that sub1 has been removed
  });
});
