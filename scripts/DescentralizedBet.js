async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying Contracts with account: ", deployer.address);

  const DescentralizedBet = await ethers.getContractFactory("DescentralizedBet");
  const descentralizedBet = await DescentralizedBet.deploy();

  await descentralizedBet.deployed();
  console.log("DescentralizedBet deployed to:", descentralizedBet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });