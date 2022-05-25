const { expect } = require("chai");
const { ethers } = require("hardhat");
const { expectRevert } = require("@openzeppelin/test-helpers");
let OceanaFactory, OceanaContract;
let accounts;
describe("ERC1155Oceana - test0", function () {
  beforeEach(async function () {
    accounts = await hre.ethers.getSigners();
    OceanaFactory = await ethers.getContractFactory("FavNFT");
    OceanaContract = await OceanaFactory.deploy();
    await OceanaContract.deployed();
    await OceanaContract.createFav("https://oceana.data/0.json");
  });
  it("Revert if Fav is not created by owner of Oceana contract", async function () {
    await expectRevert(
      OceanaContract.connect(accounts[1]).createFav("https://oceana/1.json"),
      "Ownable: caller is not the owner"
    );
  });
  it("Revert if URL is not set by the owner of smart contract", async function () {
    await expectRevert(
      OceanaContract.connect(accounts[1]).setFavDataURI(
        0,
        "https://oceana/1.json"
      ),
      "Ownable: caller is not the owner"
    );
  });
  it("Create NFT if fav doesn't exist", async function () {
    await expectRevert(
      OceanaContract.createNft(
        accounts[0].address,
        1,
        100,
        "https://oceana.data/0.json",
        0x0
      ),
      "Fav doesn't exist"
    );
  });
  it("Create NFT with amount equal to 0", async function () {
    await expectRevert(
      OceanaContract.createNft(
        accounts[0].address,
        0,
        0,
        "https://oceana.data/0.json",
        0x0
      ),
      "amount is zero"
    );
  });

  it("Mint NFT to zero address", async function () {
    await expectRevert(
      OceanaContract.createNft(
        "0x0000000000000000000000000000000000000000",
        0,
        100,
        "https://oceana.data/0.json",
        0x0
      ),
      `ERC1155: mint to the zero address`
    );
  });

  it("Balance check after mint", async function () {
    await OceanaContract.createNft(
      accounts[0].address,
      0,
      80,
      "https://oceana.data/0.json",
      0x0
    );
    await OceanaContract.createNft(
      accounts[1].address,
      0,
      100,
      "https://oceana.data/1.json",
      0x0
    );
    await OceanaContract.createNft(
      accounts[2].address,
      0,
      120,
      "https://oceana.data/2.json",
      0x0
    );
    const balance = await OceanaContract.balanceOf(0, accounts[0].address, 0);
    const balanceArr = await OceanaContract.balanceOfBatch(
      0,
      [accounts[0].address, accounts[1].address, accounts[2].address],
      [0, 1, 2]
    );
    //console.log(balanceArr);
    expect(balance.toString()).to.equal("80");
    expect(balanceArr.toString()).to.eql("80,100,120");
  });
  it("Balance check after transfer", async function () {
    await OceanaContract.createNft(
      accounts[0].address,
      0,
      100,
      "https://oceana.data/0.json",
      0x0
    );
    await OceanaContract.safeTransferFrom(
      accounts[0].address,
      accounts[1].address,
      0,
      0,
      30,
      0x0
    );
    const balance1 = await OceanaContract.balanceOf(0, accounts[0].address, 0);
    const balance2 = await OceanaContract.balanceOf(0, accounts[1].address, 0);
    console.log(balance1, balance2);
    const balance = await OceanaContract.balanceOfBatch(
      0,
      [accounts[0].address, accounts[1].address],
      [0, 0]
    );
    expect(balance.toString()).to.eql("70,30");
  });
});
describe("ERC1155Oceana - test1", function () {
  beforeEach(async function () {
    accounts = await hre.ethers.getSigners();
    OceanaFactory = await ethers.getContractFactory("FavNFT");
    OceanaContract = await OceanaFactory.deploy();
    await OceanaContract.deployed();
    await OceanaContract.createFav("https://oceana.data/0.json");
    await OceanaContract.connect(accounts[0]).createNft(
      accounts[0].address,
      0,
      100,
      "https://oceana.data/0.json",
      0x0
    );
    await OceanaContract.connect(accounts[1]).createNft(
      accounts[1].address,
      0,
      100,
      "https://oceana.data/1.json",
      0x0
    );
    await OceanaContract.connect(accounts[2]).createNft(
      accounts[2].address,
      0,
      100,
      "https://oceana.data/2.json",
      0x0
    );
  });
  it("Fav's token Id check", async function () {
    const tokenId = await OceanaContract.fav2tokenId(0);
    expect(tokenId).to.equal(3);
  });
  it("Check Fav's token Id's owner", async function () {
    const owner0 = await OceanaContract.creators(0, 0);
    const owner1 = await OceanaContract.creators(0, 1);
    const owner2 = await OceanaContract.creators(0, 2);
    expect(owner0).to.equal(accounts[0].address);
    expect(owner1).to.equal(accounts[1].address);
    expect(owner2).to.equal(accounts[2].address);
  });
  it("Only owner can set the URI of token Id", async function () {
    await expectRevert(
      OceanaContract.connect(accounts[1]).setTokenURI(
        0,
        0,
        "https://oceana/data0.json"
      ),
      "only creator can set uri"
    );
  });
});
