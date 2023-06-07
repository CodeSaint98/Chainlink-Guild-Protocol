const { ethers } = require("hardhat");
async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
    const initial_supply = ethers.utils.parseEther("100000000");
    //deployment variables
    const GuildTokenContract = await ethers.getContractFactory("GuildToken");
    const ValidatorSelectionContract = await ethers.getContractFactory("ValidatorSelection");
    const ClientInterfaceContract = await ethers.getContractFactory("ClientInterface");
    //deployment
    const GuildToken = await GuildTokenContract.deploy(initial_supply);
    const ValidatorSelection = await ValidatorSelectionContract.deploy(GuildToken.address);
    const ClientInterface = await ClientInterfaceContract.deploy(GuildToken.address,ValidatorSelection.address);
    console.log("GuildToken Contract", GuildToken.address);
    console.log("ValidatorSelection Contract", ValidatorSelection.address);
    console.log("Client Interface Contract", ClientInterface.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });