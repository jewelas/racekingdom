// test/Rematic.proxy.js
// Load dependencies
const { expect } = require('chai');

let RaceKingdom;
let RKVesting;
let RKStaking;
let mainContract;
let vestingContract;
let stakingContract;

// Start test block
describe('Racekingdom', function () {
  beforeEach(async function () {
    RaceKingdom = await ethers.getContractFactory("RaceKingdom")
    RKVesting = await ethers.getContractFactory("RKVesting")
    RKStaking = await ethers.getContractFactory("RKStaking")
  
    mainContract = await RaceKingdom.deploy()
    await mainContract.deployed()
    
    
    vestingContract = await RKVesting.deploy(mainContract.address)
    await vestingContract.deployed()
    
    
    // stakingContract = await RKStaking.deploy(mainContract.address, vestingContract.address)
    // await stakingContract.deployed()
    await vestingContract.Trigger()

  });

  // Test case
  it('Basic Token Contract deployed correctly.', async function () {
    expect((await mainContract.symbol()).toString()).to.equal('RKPO');
  });

  it('Vesting Contract was triggered correctly.', async function () {
    expect((await vestingContract.Month())).to.equal(1);
});
});