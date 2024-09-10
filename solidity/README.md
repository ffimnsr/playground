# Playground Solidity

## Development using Hardhat

1. Initialize an empty repository using `pnpm init`.
2. After that install the hardhat cli locally using `pnpm add -D hardhat`.
3. Run the hardhat with `npx hardhat`. Just select the empty project.
4. Install all the dependency library that you may need in development. Here are some:

    ```
    pnpm add -D @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
    ```

5. Add the needed require to run locally the hardhat setup. You need to modify `hardhat.config.ts`.

    ```
    require("@nomiclabs/hardhat-waffle");
    ```

6. Add needed network in the same config file.
7. Build and run.
8. To make it typescript add the following dependencies.

    ```
    pnpm add -D @types/chai @types/mocha @types/node ts-node
    pnpm add typescript 
    ```

9. Install additional optional libraries:

    ```
    pnpm add -D rimraf dotenv @openzeppelin/contracts
    ```