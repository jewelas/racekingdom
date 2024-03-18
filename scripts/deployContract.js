async function main() {
  const Contract = await ethers.getContractFactory("Bittenser");

  const contract = await Contract.deploy();
  await contract.deployed();

  console.log("Contract deployed to address:", contract.address); //0x2Bca6B22970A200EbBF76cC69C7a23808967E378
  //https://testnet.bscscan.com/address/0x2Bca6B22970A200EbBF76cC69C7a23808967E378#code
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
