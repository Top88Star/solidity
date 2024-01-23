-include .env

build:; forge build

test :; forge test

deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(ETHER_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast