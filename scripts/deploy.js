async function main() {
    const RaceKingdom = await ethers.getContractFactory("RaceKingdom")
    const RKVesting = await ethers.getContractFactory("RKVesting")
    const RKStaking = await ethers.getContractFactory("RKStaking")
  
    const mainContract = await RaceKingdom.deploy()
    await mainContract.deployed()
    
    
    const vestingContract = await RKVesting.deploy(mainContract.address)
    await vestingContract.deployed()
    
    
    // const stakingContract = await RKStaking.deploy(mainContract.address, vestingContract.address)
    // await stakingContract.deployed()

    const month = await vestingContract.Month();
    console.log("month: ", month);

    console.log("Main Contract deployed to address:", mainContract.address)
    console.log("Vesting Contract deployed to address:", vestingContract.address)
    // console.log("Staking Contract deployed to address:", stakingContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  