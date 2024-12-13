require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      accounts: [
        "0xddf186adadb92ce94f1c1ac5886846c2952a73d55242300ba0da0282988d07e0",
        "0x67de66601ab6dfb95ff796bb3deebaa8f59e1f9967014e9abab7ac7460713206",
        "0x76c92147c2823e91ab73db46eabcdd0266ecef03c1b4a243006d04cc9b4b66f2",
        "0x6ca1f861de1cce48d788da47fc23da2dc301e8e8155013642fcdb6d69f161224",
        "0x122920e6bb42876bd80f6e80a2805750adeee62af00cd20bfe6d3fe6451334ee",
      ],
    },
  },
};
