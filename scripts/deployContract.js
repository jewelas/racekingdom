async function main() {
  const Contract = await ethers.getContractFactory("SeaGateA");
  // const Contract = await ethers.getContractFactory("Bittenser");

  const contract = await Contract.deploy();
  await contract.deployed();

  console.log("Contract deployed to address:", contract.address); //0xCc1e099beF74fc2788b1836F2460F70B9734cddF
  //https://testnet.bscscan.com/address/0xCc1e099beF74fc2788b1836F2460F70B9734cddF#code
}

main()
  .then(() => process.exit(0))
  .catch((error) => { 
    console.error(error);
    process.exit(1);
  });
