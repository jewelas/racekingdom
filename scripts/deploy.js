async function main() {
    const RaceKingdom = await ethers.getContractFactory("RaceKingdom")
    const RKVesting = await ethers.getContractFactory("RKVesting")
    const RKStaking = await ethers.getContractFactory("RKStaking")
  
    const mainContract = await RaceKingdom.deploy()
    await mainContract.deployed()
    
    
    const vestingContract = await RKVesting.deploy(mainContract.address)
    await vestingContract.deployed()
    
    
    const stakingContract = await RKStaking.deploy(mainContract.address, vestingContract.address)
    await stakingContract.deployed()

    // const stakingContract = await RKStaking.deploy("0x9003D6385DdD5aE24F535E525488b9B2659083C1", "0x886A5a6f5452E7d2C492684b40319D2abc1EcE05")
    // await stakingContract.deployed()

    console.log("Main Contract deployed to address:", mainContract.address)
    console.log("Vesting Contract deployed to address:", vestingContract.address)
    console.log("Staking Contract deployed to address:", stakingContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  