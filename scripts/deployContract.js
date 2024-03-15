async function main() {
  const Contract = await ethers.getContractFactory("Bittenser");

  const contract = await Contract.deploy();
  await contract.deployed();

  console.log("Contract deployed to address:", contract.address); //0xbE3D68236A0402cDa2Bd78D2B24D47e5Ad3c1af3
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
