async function main() {
    const Seductions = await ethers.getContractFactory("Seductions")
  
    // Start deployment, returning a promise that resolves to a contract object
    const myContract = await Seductions.deploy()
    await myContract.deployed()
    console.log("Contract deployed to address:", myContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  