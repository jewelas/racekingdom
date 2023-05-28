async function main() {
    const PepeBorn = await ethers.getContractFactory("PepeBorn")
    // const RKVesting = await ethers.getContractFactory("RKVesting")
  
    const mainContract = await PepeBorn.deploy()
    await mainContract.deployed()
    
    
    // const vestingContract = await RKVesting.deploy(mainContract.address)
    // await vestingContract.deployed()

    console.log("Main Contract deployed to address:", mainContract.address)
    // console.log("Vesting Contract deployed to address:", vestingContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  