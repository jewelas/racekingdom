// test/Rematic.proxy.js
// Load dependencies
const { expect } = require("chai");
const { BigNumber } = require("ethers");

let RaceKingdom;
let RKVesting;
let mainContract;
let vestingContract;

// Start test block
describe("Racekingdom", function () {
  beforeEach(async function () {
    RaceKingdom = await ethers.getContractFactory("RaceKingdom");
    RKVesting = await ethers.getContractFactory("RKVesting");

    mainContract = await RaceKingdom.deploy();
    await mainContract.deployed();

    vestingContract = await RKVesting.deploy(mainContract.address);
    await vestingContract.deployed();

  });

  // Test case
  it("Basic Token Contract works correctly.", async function () {
    expect((await mainContract.symbol()).toString()).to.equal("ATOZ");

    const [addr1, addr2] = await ethers.getSigners();

    //mint
    await mainContract.mint(addr1.address, 50);

    //balanceOf
    expect(BigNumber.from(await mainContract.balanceOf(addr1.address))).to.deep.equal(BigNumber.from("50"));

    //transfer
    await mainContract.connect(addr1).transfer(addr2.address, 50);
    expect(BigNumber.from(await mainContract.balanceOf(addr2.address))).to.deep.equal(BigNumber.from("50"));
  });

});
