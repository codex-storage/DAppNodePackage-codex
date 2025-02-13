#!/bin/bash

# Environment variables from files
# If set to file path, read the file and export the variables
# If set to directory path, read all files in the directory and export the variables
if [[ -n "${ENV_PATH}" ]]; then
  set -a
  [[ -f "${ENV_PATH}" ]] && source "${ENV_PATH}" || for f in "${ENV_PATH}"/*; do source "$f"; done
  set +a
fi

# Parameters
if [[ -z "${CODEX_NAT}" ]]; then
  if [[ "${NAT_IP_AUTO}" == "true" && -z "${NAT_PUBLIC_IP_AUTO}" ]]; then
    export CODEX_NAT=$(hostname --ip-address)
    echo "Private: CODEX_NAT=${CODEX_NAT}"
  elif [[ -n "${NAT_PUBLIC_IP_AUTO}" ]]; then
    # Run for 60 seconds if fail
    WAIT=120
    SECONDS=0
    SLEEP=5
    while (( SECONDS < WAIT )); do
      export CODEX_NAT=$(curl -s -f -m 5 "${NAT_PUBLIC_IP_AUTO}")
      # Check if exit code is 0 and returned value is not empty
      if [[ $? -eq 0 && -n "${CODEX_NAT}" ]]; then
        echo "Public: CODEX_NAT=${CODEX_NAT}"
        break
      else
        # Sleep and check again
        echo "Can't get Public IP - Retry in $SLEEP seconds / $((WAIT - SECONDS))"
        sleep $SLEEP
      fi
    done
  fi
fi

# Stop Codex run if can't get NAT IP when requested
if [[ "${NAT_IP_AUTO}" == "true" && -z "${CODEX_NAT}" ]]; then
  echo "Can't get Private IP - Stop Codex run"
  exit 1
elif [[ -n "${NAT_PUBLIC_IP_AUTO}" && -z "${CODEX_NAT}" ]]; then
  echo "Can't get Public IP in $WAIT seconds - Stop Codex run"
  exit 1
fi

# If marketplace is enabled from the testing environment,
# The file has to be written before Codex starts.
for key in PRIV_KEY ETH_PRIVATE_KEY; do
  keyfile="private.key"
  if [[ -n "${!key}" ]]; then
    [[ "${key}" == "PRIV_KEY" ]] && echo "PRIV_KEY variable is deprecated and will be removed in the next releases, please use ETH_PRIVATE_KEY instead!"
    echo "${!key}" > "${keyfile}"
    chmod 600 "${keyfile}"
    export CODEX_ETH_PRIVATE_KEY="${keyfile}"
    echo "Private key set"
  fi
done

# Set arguments
if [[ "${MODE}" == "codex-node-with-marketplace" ]]; then
  set -- "$@" persistence
  [[ -z "${CODEX_MARKETPLACE_ADDRESS}" ]] && unset CODEX_MARKETPLACE_ADDRESS
elif [[ "${MODE}" == "codex-storage-node" ]]; then
  set -- "$@" persistence prover
else
  unset CODEX_ETH_PROVIDER
fi

# Set network parameters
if [[ "${NETWORK}" == "testnet" ]]; then
  bootstrap_nodes=(
    --bootstrap-node=spr:CiUIAhIhAiJvIcA_ZwPZ9ugVKDbmqwhJZaig5zKyLiuaicRcCGqLEgIDARo8CicAJQgCEiECIm8hwD9nA9n26BUoNuarCEllqKDnMrIuK5qJxFwIaosQ3d6esAYaCwoJBJ_f8zKRAnU6KkYwRAIgM0MvWNJL296kJ9gWvfatfmVvT-A7O2s8Mxp8l9c8EW0CIC-h-H-jBVSgFjg3Eny2u33qF7BDnWFzo7fGfZ7_qc9P
    --bootstrap-node=spr:CiUIAhIhAyUvcPkKoGE7-gh84RmKIPHJPdsX5Ugm_IHVJgF-Mmu_EgIDARo8CicAJQgCEiEDJS9w-QqgYTv6CHzhGYog8ck92xflSCb8gdUmAX4ya78QoemesAYaCwoJBES39Q2RAnVOKkYwRAIgLi3rouyaZFS_Uilx8k99ySdQCP1tsmLR21tDb9p8LcgCIG30o5YnEooQ1n6tgm9fCT7s53k6XlxyeSkD_uIO9mb3
    --bootstrap-node=spr:CiUIAhIhA6_j28xa--PvvOUxH10wKEm9feXEKJIK3Z9JQ5xXgSD9EgIDARo8CicAJQgCEiEDr-PbzFr74--85TEfXTAoSb195cQokgrdn0lDnFeBIP0QzOGesAYaCwoJBK6Kf1-RAnVEKkcwRQIhAPUH5nQrqG4OW86JQWphdSdnPA98ErQ0hL9OZH9a4e5kAiBBZmUl9KnhSOiDgU3_hvjXrXZXoMxhGuZ92_rk30sNDA
    --bootstrap-node=spr:CiUIAhIhA7E4DEMer8nUOIUSaNPA4z6x0n9Xaknd28Cfw9S2-cCeEgIDARo8CicAJQgCEiEDsTgMQx6vydQ4hRJo08DjPrHSf1dqSd3bwJ_D1Lb5wJ4Qt_CesAYaCwoJBEDhWZORAnVYKkYwRAIgFNzhnftocLlVHJl1onuhbSUM7MysXPV6dawHAA0DZNsCIDRVu9gnPTH5UkcRXLtt7MLHCo4-DL-RCMyTcMxYBXL0
    --bootstrap-node=spr:CiUIAhIhAzZn3JmJab46BNjadVnLNQKbhnN3eYxwqpteKYY32SbOEgIDARo8CicAJQgCEiEDNmfcmYlpvjoE2Np1Wcs1ApuGc3d5jHCqm14phjfZJs4QrvWesAYaCwoJBKpA-TaRAnViKkcwRQIhANuMmZDD2c25xzTbKSirEpkZYoxbq-FU_lpI0K0e4mIVAiBfQX4yR47h1LCnHznXgDs6xx5DLO5q3lUcicqUeaqGeg
    --bootstrap-node=spr:CiUIAhIhAgybmRwboqDdUJjeZrzh43sn5mp8jt6ENIb08tLn4x01EgIDARo8CicAJQgCEiECDJuZHBuioN1QmN5mvOHjeyfmanyO3oQ0hvTy0ufjHTUQh4ifsAYaCwoJBI_0zSiRAnVsKkcwRQIhAJCb_z0E3RsnQrEePdJzMSQrmn_ooHv6mbw1DOh5IbVNAiBbBJrWR8eBV6ftzMd6ofa5khNA2h88OBhMqHCIzSjCeA
    --bootstrap-node=spr:CiUIAhIhAntGLadpfuBCD9XXfiN_43-V3L5VWgFCXxg4a8uhDdnYEgIDARo8CicAJQgCEiECe0Ytp2l-4EIP1dd-I3_jf5XcvlVaAUJfGDhry6EN2dgQsIufsAYaCwoJBNEmoCiRAnV2KkYwRAIgXO3bzd5VF8jLZG8r7dcLJ_FnQBYp1BcxrOvovEa40acCIDhQ14eJRoPwJ6GKgqOkXdaFAsoszl-HIRzYcXKeb7D9
  )
fi

# Update arguments
set -- "$@" ${bootstrap_nodes[@]} ${EXTRA_OPTS}

# Check if the endpoint is synced
if [[ -n "${CODEX_ETH_PROVIDER}" ]]; then
  echo "Marketplace is enabled - Check if the endpoint is synced"

  timeout=3
  interval=5
  endpoint="${CODEX_ETH_PROVIDER}"
  while true; do
    block=$(curl -m $timeout -X POST \
      -s "${CODEX_ETH_PROVIDER}" \
      -H 'Content-Type: application/json' \
      -d '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false],"id":0}' | jq -r '.result.number')
    block=$(("${block}"))
    sync=$(curl -m $timeout -X POST \
      -s "${CODEX_ETH_PROVIDER}" \
      -H 'Content-Type: application/json' \
      -w %{time_total} \
      -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')
    sync=$(echo $sync | tr '\n' ' ')
    if [[ $sync == *false* ]]; then
      echo "$(date) - Endpoint ${endpoint} is Synced, go to run - block $block - $sync"
      break
    else
      echo "$(date) - Endpoint ${endpoint} is Not synced, waiting - block $block - $sync"
    fi
    sleep $interval
  done
else
  echo "Marketplace is disabled - Skip endpoint sync check"
fi

# Circuit downloader
# cirdl [circuitPath] [rpcEndpoint] [marketplaceAddress]
if [[ "$@" == *"prover"* ]]; then
  echo "Prover is enabled - Run Circuit downloader"

  # Set variables required by cirdl from command line arguments when passed
  for arg in data-dir circuit-dir eth-provider marketplace-address; do
    arg_value=$(grep -o "${arg}=[^ ,]\+" <<< $@ | awk -F '=' '{print $2}')
    if [[ -n "${arg_value}" ]]; then
      var_name=$(tr '[:lower:]' '[:upper:]' <<< "CODEX_${arg//-/_}")
      export "${var_name}"="${arg_value}"
    fi
  done

  # Set circuit dir from CODEX_CIRCUIT_DIR variables if set
  if [[ -z "${CODEX_CIRCUIT_DIR}" ]]; then
    export CODEX_CIRCUIT_DIR="${CODEX_DATA_DIR}/circuits"
  fi

  # Download circuit
  mkdir -p "${CODEX_CIRCUIT_DIR}"
  chmod 700 "${CODEX_CIRCUIT_DIR}"
  download="cirdl ${CODEX_CIRCUIT_DIR} ${CODEX_ETH_PROVIDER} ${CODEX_MARKETPLACE_ADDRESS}"
  echo "${download}"
  eval "${download}"
  [[ $? -ne 0 ]] && { echo "Failed to download circuit files"; exit 1; }
fi

# Show
echo "Codex parameters:"
vars=$(env | grep CODEX_)
echo -e "${vars//CODEX_/   - CODEX_}"
echo -e "   $@"

# Run
echo "Run Codex node..."
exec "$@"
