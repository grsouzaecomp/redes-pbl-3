async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying Contracts with account: ", deployer.address);

  const DecentralizedBet = await ethers.getContractFactory("DescentralizedBet");
  const decentralizedBet = await DecentralizedBet.deploy();

  await decentralizedBet.deployed();
  console.log("DescentralizedBet deployed to:", decentralizedBet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });