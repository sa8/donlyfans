const { ethers } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("dOnlyFans contract", function () {
  async function deployDOnlyFansFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const dOnlyFans = await ethers.getContractFactory("dOnlyFans");

    const hardhatDOnlyFans = await dOnlyFans.deploy();

    await hardhatDOnlyFans.deployed();

    const createProfile = await hardhatDOnlyFans.createProfile(2);

    const firstSubscription = await hardhatDOnlyFans
      .connect(addr1)
      .subscribe(owner.address, {
        value: ethers.utils.parseEther("2.0"),
      });

    // Fixtures can return anything you consider useful for your tests
    return { dOnlyFans, hardhatDOnlyFans, owner, addr1, addr2 };
  }
  it("Verify subscription", async function () {
    const { hardhatDOnlyFans, owner, addr1 } = await loadFixture(
      deployDOnlyFansFixture
    );
    //console.log(createProfile);
    const [subs] = await hardhatDOnlyFans.getSubscribers(owner.address);
    console.log(subs);
    console.log(addr1.address);
    expect(subs).to.equal(addr1.address);
  });

  // it("Unsubscribing", async function () {
  //   const { hardhatDOnlyFans, owner, addr1, addr2 } = await loadFixture(
  //     deployDOnlyFansFixture
  //   );
  //   const secondSubscription = await hardhatDOnlyFans
  //     .connect(addr2)
  //     .subscribe(owner.address, {
  //       value: ethers.utils.parseEther("2.0"),
  //     });

  //   const unsub = await hardhatDOnlyFans
  //     .connect(addr1)
  //     .unsubscribe(owner.address);

  //   const subs = await hardhatDOnlyFans.getSubscribers(owner.address);
  //   console.log(subs);
  //   //expect(subs).to.equal(addr2.address);
  // });
});
