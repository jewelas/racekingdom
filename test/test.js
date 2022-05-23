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

const delay = ms => new Promise(res => setTimeout(res, ms));

// Start test block
describe("Racekingdom", function () {
  beforeEach(async function () {
    RaceKingdom = await ethers.getContractFactory("RaceKingdom");
    RKVesting = await ethers.getContractFactory("RKVesting");
    RKStaking = await ethers.getContractFactory("RKStaking");

    mainContract = await RaceKingdom.deploy();
    await mainContract.deployed();

    vestingContract = await RKVesting.deploy(mainContract.address);
    await vestingContract.deployed();



    stakingContract = await RKStaking.deploy(mainContract.address, vestingContract.address)
    await stakingContract.deployed()

  });

  // Test case
  it("Basic Token Contract works correctly.", async function () {
    expect((await mainContract.symbol()).toString()).to.equal("RKPO");

    const [addr1, addr2] = await ethers.getSigners();

    //mint
    await mainContract.mint(addr1.address, 50);

    //balanceOf
    expect(BigNumber.from(await mainContract.balanceOf(addr1.address))).to.deep.equal(BigNumber.from("50"));

    //transfer
    await mainContract.connect(addr1).transfer(addr2.address, 50);
    expect(BigNumber.from(await mainContract.balanceOf(addr2.address))).to.deep.equal(BigNumber.from("50"));
  });

  it("Vesting and Staking contracts are working correctly.", async function () {
    //Trigger vesting contract.
    await vestingContract.Trigger();

    //Get current month
    //test Month(), getMonth()
    expect(parseInt(await vestingContract.Month())).to.equal(1);

    //Set Vesting Amounts.
    await vestingContract.SetSeedRoundVestingAmount(toBigNumberArray(seedRoundVestingAmount));
    expect(await vestingContract.SeedRoundVestingAmount()).to.deep.equal(toBigNumberArray(seedRoundVestingAmount));

    await vestingContract.SetPrivateRoundVestingAmount(toBigNumberArray(privateRoundVestingAmount));
    expect(await vestingContract.PrivateRoundVestingAmount()).to.deep.equal(toBigNumberArray(privateRoundVestingAmount));

    await vestingContract.SetPublicRoundVestingAmount(toBigNumberArray(publicRoundVestingAmount));
    expect(await vestingContract.PublicRoundVestingAmount()).to.deep.equal(toBigNumberArray(publicRoundVestingAmount));

    await vestingContract.SetTeamVestingAmount(toBigNumberArray(teamVestingAmount));
    expect(await vestingContract.TeamVestingAmount()).to.deep.equal(toBigNumberArray(teamVestingAmount));

    await vestingContract.SetAdvisorsVestingAmount(toBigNumberArray(advisorsVestingAmount));
    expect(await vestingContract.AdvisorsVestingAmount()).to.deep.equal(toBigNumberArray(advisorsVestingAmount));

    await vestingContract.SetP2EVestingAmount(toBigNumberArray(p2eVestingAmount));
    expect(await vestingContract.P2EVestingAmount()).to.deep.equal(toBigNumberArray(p2eVestingAmount));

    await vestingContract.SetStakingVestingAmount(toBigNumberArray(stakingRewardVestingAmount30), toBigNumberArray(stakingRewardVestingAmount60), toBigNumberArray(stakingRewardVestingAmount90));

    await vestingContract.SetEcosystemVestingAmount(toBigNumberArray(ecosystemVestingAmount));
    expect(await vestingContract.EcosystemVestingAmount()).to.deep.equal(toBigNumberArray(ecosystemVestingAmount));


    //Get 90 APY ceiling for Q1.
    //getAPY, quarterTotalStaked90, quarterStake90Of
    expect(await stakingContract.getAPY(BigNumber.from(await vestingContract.start()), 90)).to.deep.equal(BigNumber.from(12306));

    //getAPY, quarterTotalStaked60, quarterStake60Of
    expect(await stakingContract.getAPY(BigNumber.from(await vestingContract.start()), 60)).to.deep.equal(BigNumber.from(1844));

    //getAPY, quarterTotalStaked30, quarterStake30Of
    expect(await stakingContract.getAPY(BigNumber.from(await vestingContract.start()), 30)).to.deep.equal(BigNumber.from(943));


    //Stake amount of 1000000000000000000.
    const [addr1] = await ethers.getSigners();

    //test mint function of token contract.
    await mainContract.mint(addr1.address, BigNumber.from("1000000000000000000"));

    //test approve function of token contract.
    await mainContract.connect(addr1).approve(stakingContract.address, BigNumber.from("1000000000000000000"));

    //test createStake function of Staking contract.
    //createStake, addStakeholder.
    await stakingContract.connect(addr1).createStake(BigNumber.from("1000000000000000000"), 30);

    //test isStakeholder function.
    expect(await stakingContract.isStakeholder(addr1.address)).to.deep.equal(true);

    //test stakeOf function.
    expect(await stakingContract.stakeOf(addr1.address)).to.deep.equal(BigNumber.from("1000000000000000000"));

    //test totalStakes function.
    expect(await stakingContract.totalStakes()).to.deep.equal(BigNumber.from("1000000000000000000"));

    await delay(30000);

    //rewardsOf
    expect(await stakingContract.rewardsOf(addr1.address)).to.deep.equal(BigNumber.from("94300000000000000"));

    // //totalRewards.
    // expect(await stakingContract.totalRewards()).to.deep.equal(BigNumber.from("94300000000000000"));

    // //remove stake amount of 500000000000000000.
    // //test claim, removeStake, removeStakeholder, claimReward, removableStake  function of Staking contract.
    // await stakingContract.connect(addr1).claim();
    // await delay(27000);

    // //withdrawClaimed
    // await stakingContract.connect(addr1).withdrawClaimed();
    // expect(BigNumber.from(await mainContract.balanceOf(addr1.address))).to.deep.equal(BigNumber.from("1094300000000000000"));


    // expect(await stakingContract.stakeOf(addr1.address)).to.deep.equal(BigNumber.from("0"));
    // expect(await stakingContract.totalStakes()).to.deep.equal(BigNumber.from("0"));
  });
});
