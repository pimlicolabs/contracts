#!/bin/bash

# set -e

source .env

# Split the CHAIN_KEYS variable by comma, then iterate over each pair
IFS=',' read -r -a pairs <<< "$CHAIN_KEYS"
for pair in "${pairs[@]}"; do
  # Split each pair by '='
  
  IFS=';' read -r -a kv <<< "$pair"
  RPC_URL="${kv[0]}"
  ETHERSCAN_KEY="${kv[1]}"
  ETHERSCAN_URL="${kv[2]}"

  echo "Deploying to $RPC_URL, verifying with $ETHERSCAN_URL using key $ETHERSCAN_KEY"

  forge script script/PimlicoEntryPointSimulations.s.sol:PimlicoEntryPointSimulationsScript \
    --rpc-url "$RPC_URL" \
    --account pimlico-utility \
    --broadcast \
    -vvvv

  # Verify contracts only if ETHERSCAN_KEY and ETHERSCAN_URL are provided
  if [[ -n "$ETHERSCAN_KEY" && -n "$ETHERSCAN_URL" ]]; then
    echo "Verifying with $ETHERSCAN_URL using key $ETHERSCAN_KEY"

    forge verify-contract 0xb02456A0eC77837B22156CBA2FF53E662b326713 src/PimlicoEntryPointSimulations.sol:PimlicoEntryPointSimulations \
      --verifier-url "$ETHERSCAN_URL" \
      --etherscan-api-key "$ETHERSCAN_KEY"

    forge verify-contract 0xda121459aeFC83948C76345E27551f1269b7853b src/EntryPointSimulations.sol:EntryPointSimulations \
      --verifier-url "$ETHERSCAN_URL" \
      --etherscan-api-key "$ETHERSCAN_KEY"

  else
    echo "Skipping contract verification as ETHERSCAN_KEY and/or ETHERSCAN_URL are not provided."
  fi


  # Use CHAIN and KEY as needed
  # Example: echo "https://$CHAIN.rpc.thirdweb.com/$KEY"
  
  # Insert your deployment and verification commands here
done
