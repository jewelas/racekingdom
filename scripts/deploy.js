async function main() {
    const MBGA = await ethers.getContractFactory("MBGA")
  
    const mainContract = await MBGA.deploy()
    await mainContract.deployed()
    
    

    console.log("Main Contract deployed to address:", mainContract.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  