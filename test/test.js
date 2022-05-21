// test/Rematic.proxy.js
// Load dependencies
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { stakingRewardVestingAmount30, 
  stakingRewardVestingAmount60, 
  stakingRewardVestingAmount90, 
  seedRoundVestingAmount, 
  privateRoundVestingAmount, 
  publicRoundVestingAmount, 
  teamVestingAmount, 
  advisorsVestingAmount, 
  p2eVestingAmount, 
  ecosystemVestingAmount 
} = require("../scripts/testData");

let RaceKingdom;
let RKVesting;
let RKStaking;
let mainContract;
let vestingContract;
let stakingContract;

const toBigNumberArray = (arr) => {
  const newArr = [];
  arr.map((item) => {
    newArr.push(BigNumber.from(item));
  })
  return newArr;
}

// Start test block
describe("Racekingdom", function () {
  beforeEach(async function () {
    RaceKingdom = await ethers.getContractFactory("RaceKingdom");
    RKVesting = await ethers.getContractFactory("RKVesting");
    RKStaking = await ethers.getContractFactory("RKStaking");

    mainContract = await RaceKingdom.deploy();
    await mainContract.deployed();

    // vestingContract = await RKVesting.deploy(mainContract.address);
    // await vestingContract.deployed();

    

    // stakingContract = await RKStaking.deploy(mainContract.address, vestingContract.address)
    // await stakingContract.deployed()
  });

  // Test case
  it("Basic Token Contract deployed correctly.", async function () {
    expect((await mainContract.symbol()).toString()).to.equal("RKPO");

    const [addr1, addr2] = await ethers.getSigners();
    await mainContract.mint(addr1.address, 50);
    expect(await mainContract.balanceOf(addr1.address)).to.equal(50);
  });

  // it("Vesting Contract was triggered correctly.", async function () {
  //   expect(parseInt(await vestingContract.Month())).to.equal(1);
  //   await vestingContract.SetSeedRoundVestingAmount(toBigNumberArray(seedRoundVestingAmount));
  //   expect(await vestingContract.SeedRoundVestingAmount()).to.equal(seedRoundVestingAmount);
  // });
});
