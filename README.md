# Codex Dappnode packages

<p align="center" width="100%">
  <img src="avatar-codex.png" alt="Codex Dappnode package" />
</p>


## Description

 [Codex](https://codex.storage) is a durable, decentralised storage protocol designed to safeguard the world's most valuable information.

 Repository contains code to build Dappnode packages for Codex
 - `Codex`
 - `Codex local Geth`

 We should select `Codex` package in case we would like to run Codex and use a Public RPC endpoint.

 If we would like to run in a full P2P manner, `Codex local Geth` package contains additionally local Geth node and Codex will use it instead of the Public RPC endpoint.


## Installation

 > [!NOTE]
 > This code is in a **preview mode** and can be installed only from local builds. Please check [Development](docs/README.md#development) documentation for more details.
 ```shell
 # Clone
 git clone https://github.com/codex-storage/DAppNodePackage-codex

 # Directory
 cd DAppNodePackage-codex

 # Build all packages (~ 10 minutes) - use your IPFS package Container IP
 npx @dappnode/dappnodesdk build --all-variants --provider=http://172.33.0.6:5001
 ```

  | Package               | Link                                                                                                                                                   |
  | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | Codex                 | [`/ipfs/QmRobj7vPQ7qJBG42iD8c75SAoMkG1pr1YetYD5QHJNrdz`](http://my.dappnode/installer/public/%2Fipfs%2FQmRobj7vPQ7qJBG42iD8c75SAoMkG1pr1YetYD5QHJNrdz) |
  | Codex with local Geth | [`/ipfs/QmVwJtetY98Y1mVwQ3ULwha1tiE49jVn3DQEFigdtbRjj6`](http://my.dappnode/installer/public/%2Fipfs%2FQmVwJtetY98Y1mVwQ3ULwha1tiE49jVn3DQEFigdtbRjj6) |


## Todo

 1. Automate package publishing using [GitHub Actions](https://docs.dappnode.io/docs/dev/github-actions). 
 2. Add metrics support based on the [DAppNodePackage-DMS](https://github.com/dappnode/DAppNodePackage-DMS).


## Known issues

 1. Dappnode [Setup Wizard](https://docs.dappnode.io/docs/dev/references/setup-wizard) and UI does not permit to update port mapping port for container. And in that case we are using a default value, which is set to `8090` and appropriate Codex variable `CODEX_DISC_PORT=8090` - these values are **hardcoded** in the [docker-compose.yml](docker-compose.yml).

    This also is a Codex limitation, because for DHT peers connection, we are using `src-ip:src-port` information and this can't be changed now. So, listener port must be equal with the forwarded one.

    A single way to bypass that is to update, after installation, `CODEX_DISC_PORT` variable to the new value and add a new port forwarding in the the package Network settings.

 2. Dappnode [Setup Wizard](https://docs.dappnode.io/docs/dev/references/setup-wizard) is not supported for [Multi-Config Package](https://docs.dappnode.io/docs/dev/package-development/multi-configuration), so our main *setup-wizard.yml* does not contain any settings for Geth configuration and we are using all hardcoded values.
