const { expect } = require("chai");

describe("Rush Solver Test", function () {
  let deployer;
  let rushSolver;
  before(async function(){
    [deployer] = await hre.ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const RushSolver = await hre.ethers.getContractFactory("RushHourSolver");
    rushSolver = await RushSolver.deploy();
    await rushSolver.deployed();
  })
  it("Rush Solving:", async function () {
    console.log(`token bought successfully at address: ${rushSolver.address}`);

    let sa = [
      [2, 2, 2, 0, 0, 0],
      [0, 0, 0, 0, 0, 3],
      [1, 1, 0, 0, 0, 3],
      [5, 0, 4, 0, 6, 6],
      [5, 0, 4, 0, 7, 0],
      [8, 8, 8, 0, 7, 0]
    ];  
    const res = await rushSolver.RushHourSolve(sa);
    console.log(res);
    expect(res).to.equal(true);
  });
});
