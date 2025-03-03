async function main() {
    const RaceKingdom = await ethers.getContractFactory("RaceKingdom")
  
    const mainContract = await RaceKingdom.deploy()
    await mainContract.deployed()
    
    

    console.log("Main Contract deployed to address:", mainContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  