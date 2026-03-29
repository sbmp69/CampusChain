import { ethers } from "ethers";
import fs from "fs";

async function main() {
  const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
  // Hardhat's default Account #0 private key
  const wallet = new ethers.Wallet("0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider);

  console.log("Deploying contracts with account:", wallet.address);

  let currentNonce = await wallet.getNonce();
  
  // Deploy Identity
  const identityJson = JSON.parse(fs.readFileSync('./artifacts/contracts/CampusIdentity.sol/CampusIdentity.json', 'utf8'));
  const IdentityFactory = new ethers.ContractFactory(identityJson.abi, identityJson.bytecode, wallet);
  const identity = await IdentityFactory.deploy({ nonce: currentNonce++ });
  await identity.waitForDeployment();
  const identityAddress = await identity.getAddress();
  console.log("CampusIdentity deployed to:", identityAddress);

  // Deploy Token
  const tokenJson = JSON.parse(fs.readFileSync('./artifacts/contracts/CampusToken.sol/CampusToken.json', 'utf8'));
  const TokenFactory = new ethers.ContractFactory(tokenJson.abi, tokenJson.bytecode, wallet);
  const token = await TokenFactory.deploy(identityAddress, { nonce: currentNonce++ });
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("CampusToken deployed to:", tokenAddress);

  // Deploy DAO
  const daoJson = JSON.parse(fs.readFileSync('./artifacts/contracts/CampusDAO.sol/CampusDAO.json', 'utf8'));
  const DaoFactory = new ethers.ContractFactory(daoJson.abi, daoJson.bytecode, wallet);
  const dao = await DaoFactory.deploy(identityAddress, { nonce: currentNonce++ });
  await dao.waitForDeployment();
  const daoAddress = await dao.getAddress();
  console.log("CampusDAO deployed to:", daoAddress);

  console.log("Seeding test data...");

  // Assuming methods are populated. In ethers v6, call methods directly on Contract instance
  const identityContract = new ethers.Contract(identityAddress, identityJson.abi, wallet);
  await (await identityContract.registerStudent(wallet.address, "STU-2026-001", "Meet Patel", "Computer Science", "3rd Year", { nonce: currentNonce++ })).wait();

  const tokenContract = new ethers.Contract(tokenAddress, tokenJson.abi, wallet);
  await (await tokenContract.setDistributor(wallet.address, true, { nonce: currentNonce++ })).wait();
  await (await tokenContract.earnTokens(wallet.address, 0, 1000, { nonce: currentNonce++ })).wait();
  await (await tokenContract.earnTokens(wallet.address, 1, 500, { nonce: currentNonce++ })).wait();
  await (await tokenContract.earnTokens(wallet.address, 2, 250, { nonce: currentNonce++ })).wait();

  console.log("Done! You can now use these addresses in Flutter. (Assuming they match the BlockchainService addresses!)");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
