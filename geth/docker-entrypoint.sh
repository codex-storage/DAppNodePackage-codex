#!/bin/sh

# Network
if [ "${NETWORK}" = "testnet" ]; then
  export GETH_BOOTNODES=enode://cff0c44c62ecd6e00d72131f336bb4e4968f2c1c1abeca7d4be2d35f818608b6d8688b6b65a18f1d57796eaca32fd9d08f15908a88afe18c1748997235ea6fe7@159.223.243.50:40010,enode://ea331eaa8c5150a45b793b3d7c17db138b09f7c9dd7d881a1e2e17a053e0d2600e0a8419899188a87e6b91928d14267949a7e6ec18bfe972f3a14c5c2fe9aecb@68.183.245.13:40030,enode://4a7303b8a72db91c7c80c8fb69df0ffb06370d7f5fe951bcdc19107a686ba61432dc5397d073571433e8fc1f8295127cabbcbfd9d8464b242b7ad0dcd35e67fc@174.138.127.95:40020,enode://36f25e91385206300d04b95a2f8df7d7a792db0a76bd68f897ec7749241b5fdb549a4eecfab4a03c36955d1242b0316b47548b87ad8291794ab6d3fecda3e85b@64.225.89.147:40040,enode://2e14e4a8092b67db76c90b0a02d97d88fc2bb9df0e85df1e0a96472cdfa06b83d970ea503a9bc569c4112c4c447dbd1e1f03cf68471668ba31920ac1d05f85e3@170.64.249.54:40050,enode://6eeb3b3af8bef5634b47b573a17477ea2c4129ab3964210afe3b93774ce57da832eb110f90fbfcfa5f7adf18e55faaf2393d2e94710882d09d0204a9d7bc6dd2@143.244.205.40:40060,enode://6ba0e8b5d968ca8eb2650dd984cdcf50acc01e4ea182350e990191aadd79897801b79455a1186060aa3818a6bc4496af07f0912f7af53995a5ddb1e53d6f31b5@209.38.160.40:40070
fi

# Show
echo "Geth parameters:"
vars=$(env | grep GETH_)
echo -e "${vars//GETH_/   - GETH_}"
echo -e "   $@"

# Genesis
echo "Create Genesis block"
if [ -d "${GETH_DATADIR}/geth/chaindata" ]; then
  echo "Genesis block was already created"
else
  echo "Creating Genesis block"
  echo "geth init --datadir ${GETH_DATADIR} ${GENESIS_DIR}${GENESIS_PREFIX}-${NETWORK}.json"
  geth init --datadir "${GETH_DATADIR}" "${GENESIS_DIR}${GENESIS_PREFIX}-${NETWORK}.json"
fi

# Run
echo "Run Geth node..."
geth
