async function main() {
  const Contract = await ethers.getContractFactory("Bittenser");

  const contract = await Contract.deploy();
  await contract.deployed();

  console.log("Contract deployed to address:", contract.address); //0x1Bed60bc068DD0ac9124344eA94B069590Cc44c2
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
