# Dappnode package development

 1. [Description](#description)
 2. [Server](#server)
 3. [Install](#install)
 4. [Connect](#connect)
 5. [Considerations](#considerations)
 6. [Development](#development)
 7. [Publish](#publish)
 8. [Limitations](#limitations)
 9. [Known issues](#known-issues)


## Description

 Dappnode packages supports two types of [configuration](https://docs.dappnode.io/docs/dev/package-development/overview)
  - [Single Configuration](https://docs.dappnode.io/docs/dev/package-development/single-configuration) - Used to generate a single package, tailored for a specific configuration.
  - [Multi-Configuration](https://docs.dappnode.io/docs/dev/package-development/multi-configuration) - Used to generate multiple packages with varying configurations, such as different networks or client setups.

 Provided guide is focused on Multi-Configuration variant because it provides more flexibility.

 The easiest way to develop the package is to use a VM and in that guide we will use Hetzner Cloud.

 - [Docs](https://docs.dappnode.io)
 - [Package Development](https://docs.dappnode.io/docs/dev/package-development/overview)


## Server

 1. Run an Ubuntu VM on Hetzner - `8vCPU/16GB RAM` (`cx42/cpx41`)
 2. Create firewall rules based on the [Cloud Providers / AWS](https://docs.dappnode.io/docs/user/dappnode-cloud/providers/aws/set-up-instance/) guide

    | Protocol | Port         | Service       | Source      | Comment                              |
    | -------- | ------------ | ------------- | ----------- | ------------------------------------ |
    | `TCP`    | `22`         | `SSH`         | `0.0.0.0/0` |                                      |
    | `TCP`    | `80`         | `HTTP`        | `0.0.0.0/0` | Required for services exposing only? |
    | `TCP`    | `443`        | `HTTP`        | `0.0.0.0/0` | Required for services exposing only? |
    | `UDP`    | `51820`      | `Wireguard`   | `0.0.0.0/0` |                                      |
    | `TCP`    | `1024-65535` | `General TCP` | `0.0.0.0/0` |                                      |
    | `UDP`    | `1024-65535` | `General UDP` | `0.0.0.0/0` |                                      |


## Install

 1. We can install Dappnode on Ubuntu VM using [Script installation](https://docs.dappnode.io/docs/user/install/script/)
    ```shell
    # Prerequisites
    sudo wget -O - https://prerequisites.dappnode.io | sudo bash

    # Dappnode
    sudo wget -O - https://installer.dappnode.io | sudo bash

    # Restart
    sudo reboot
    ```


## Connect

 > [!NOTE]
 > Please wait for 1-3 minutes after node was started.

 1. Check Dappnode status
    ```shell
    dappnode_status
    ```

 2. Run Dappnode if not started
    ```shell
    dappnode_start
    ```

 3. Get wireguard credentials and connect to the Dappnode instance - [WireGuard Access to Dappnode](https://docs.dappnode.io/docs/user/access-your-dappnode/vpn/wireguard/)
    ```shell
    dappnode_wireguard
    ```

 4. Open http://my.dappnode in the browser.


## Considerations

 1. Users might run a lot of different packages, which can use some standard ports like `30303`, this is why we used different default ports
    ```shell
    30303 --> 40303
    ```
    Just add 10000 to every port.


## Development

 1. Clone GitHub repository on local machine
    ```shell
    git clone https://github.com/codex-storage/DAppNodePackage-codex

    # For new package run 'init'
    # npx @dappnode/dappnodesdk init --use-variants --dir DAppNodePackage-codex
    ```
    Add you changes to the code.

 2. Copy package files to Dappnode server
    ```shell
    local_dir="DAppNodePackage-codex"
    remote_dir="/opt/DAppNodePackage-codex"
    host="root@<server-ip>"

    rsync -avze ssh --rsync-path='sudo rsync --mkpath' "${local_dir}/" "${host}:${remote_dir}/" --delete
    ```

 3. Install [Node.js](Node.js) on Dappnode server using [nvm](https://github.com/nvm-sh/nvm)
    ```shell
    # nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    # Load
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

    # Node 20
    nvm install 20

    # Check
    node --version
    # v20.18.2
    ```

 4. Install [DAppNodeSDK](https://github.com/dappnode/DAppNodeSDK) on remote Dappnode
    ```shell
    # Install
    npx -y @dappnode/dappnodesdk

    # Help
    npx @dappnode/dappnodesdk --help
    ```

 5. Get Dappnode IPFS IP: `Packages` --> `System packages` --> `Ipfs` --> `Network` --> `Container IP`

 6. Build the package
    ```shell
    # Code directory - multi-arch builds failed with --dir argument
    cd /opt/DAppNodePackage-codex

    # Use Ipfs node IP
    npx @dappnode/dappnodesdk build --all-variants --provider=http://172.33.0.2:5001
    ```
    ```
    Dappnode Package (codex.public.dappnode.eth) built and uploaded
    DNP name : codex.public.dappnode.eth
    Release hash : /ipfs/QmR7HVCpyWyDLGswF5Z1FXebrr3XjbWZeYQV2bhq5e4v1Q
    http://my.dappnode/installer/public/%2Fipfs%2FQmR7HVCpyWyDLGswF5Z1FXebrr3XjbWZeYQV2bhq5e4v1Q
    ```

 7. Install the package via DAppStore and using IPFS CID from previous step and check `Bypass only signed safe restriction`


## Publish

 - [Package Publishing](https://docs.dappnode.io/docs/dev/package-publishing/publish-packages-clients)


## Limitations

 1. Dappnode packages are built on top of the [Docker Compose](https://docs.docker.com/compose/) which has limited configuration flexibility and DAppNodeSDK does not provide any workarounds.
 2. Docker Compose base imply the following limitations
    - Variables
      - If we need to pass an optional environment variable, it needs to be defined in Compose file with some default value and it anyway will be passed to the container
      - If that optional variable can't accept a blank value, we should undefine it conditionally in the Docker entrypoint
    - Ports
      - If we need to define an optional port forwarding, it needs to be defined in Compose file with some default values and it anyway will be active and take the port on the node
      - There is no way to configure "really optional" port forwarding
      - A workaround would be use a separate package variant, but it is to big overhead
 3. We can't have a relation between variable and port forwarding, to setup same value using a single field. User have to fill separately two fields with the same value.
 4. Multi-Configuration package does not provide a real flexibility, it just generate multiple separate packages and it doesn't work like a single package with multiple options during the installation.
 5. [Using profiles with Compose](https://docs.docker.com/compose/how-tos/profiles/) is not supported.
 6. There is no way to setup a custom service name during package installation and it is predefined in the main `dappnode_package.json`
    - We can set an alias like `codex.public.dappnode --> codex-app.codex.public.dappnode`
    - That can be done for a single service in the package
 7. Is there a way to adjust container port for [Published ports](https://docs.docker.com/engine/network/#published-ports) or we can configure just host port?
 8. File [`setup-wizard.yml`](<https://docs.dappnode.io/docs/dev/references/setup-wizard>) is not supported in [Multi-Config Package Development](<https://docs.dappnode.io/docs/dev/package-development/multi-configuration>) which is very confusing. And same issue is with the `getting-started.md`.
 9. There is no way to setup custom service names for multiple services and they all namespaced under the `package name`
    ```shell
    # Public packages
          geth.codex.public.dappnode
     codex-app.codex.public.dappnode
    codex-node.codex.public.dappnode
    ```
 1. When we have Multi-Configuration package, we should define different package name for each variant, which imply different namespaces for services names and that looks not so nice, for example
    ```shell
    # Package codex
               codex.public.dappnode --> codex-app.codex.public.dappnode
     codex-app.codex.public.dappnode
    codex-node.codex.public.dappnode

    # Package codex-local-geth
               codex-local-geth.public.dappnode --> codex-app.codex-local-geth.public.dappnode
     codex-app.codex-local-geth.public.dappnode
    codex-node.codex-local-geth.public.dappnode
          geth.codex-local-geth.public.dappnode
    ```
    If we would like to have separate packages, which would permit to use same handy URL like `codex.public.dappnode` for main service, and other services under that namespace, it would be required to have separate repositories(package folders) with the same package name. It can be a cosmetic point, but it highlights a limitation we have.


## Known issues

 1. Latest [Node.js LTS release 22](https://nodejs.org/en/about/previous-releases), is not supported and we should use version 20.
 2. During local package build it is uploaded to the local IPFS node, but in the Dappnode UI package avatar is loaded from the https://gateway.ipfs.dappnode.io, so most probably it will not be shown and it is not so clear what is the issue. Maybe something is wrong with avatar or something else? We can use default avatar, which is known by Dappnode IPFS gateway.
 3. File `getting-started.md` is not specified in the official documentation, but it exists and is very usefully.
 4. Dappnodesdk does not support `compose.yaml` file, [which is default and preferred](https://docs.docker.com/compose/intro/compose-application-model/).
 5. Often time it can be more effective to [explorer existing packages](https://github.com/dappnode?q=DAppNodePackage&type=all&language=&sort=) configuration, than to use a documentation.
 6. During the package build, Docker warn that ["the attribute `version` is obsolete"](https://docs.docker.com/reference/compose-file/version-and-name/#version-top-level-element-obsolete), but dappnodesdk will fail if we remove it - that is very confusing.
