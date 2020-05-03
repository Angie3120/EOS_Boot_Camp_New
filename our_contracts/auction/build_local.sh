#!/bin/bash


################################################################################
################################ACCOUNTS########################################
################################################################################

#Create accounts for contracts
cleos create account eosio eosio.token EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio auction EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio carpool EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio tradeticket EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

#Create accounts for users
cleos create account eosio weicheng EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c
cleos create account eosio zejia EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX
cleos create account eosio aanuo EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ

#Create accounts for vtfootball and tickets
cleos create account eosio vtfootball EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7
cleos create account eosio ticket1 EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7
cleos create account eosio ticket2 EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7


################################################################################
#############################COMPILE & Deploy###################################
################################################################################

#Compile and deploy eosio.token
cd /workspace/EOS_Boot_Camp_New/existing_contracts/eosio.contracts/contracts/eosio.token
eosio-cpp -I include -o eosio.token.wasm src/eosio.token.cpp --abigen
cleos set contract eosio.token . --abi eosio.token.abi -p eosio.token@active

#Compile and deploy auction
cd /workspace/EOS_Boot_Camp_New/our_contracts/auction
eosio-cpp --abigen auction.cpp -o auction.wasm
cleos set contract auction . --abi auction.abi -p auction@active

#Compile and deploy carpool
cd /workspace/EOS_Boot_Camp_New/our_contracts/carpool
eosio-cpp --abigen carpool.cpp -o carpool.wasm -I /home/aanu/workirectory/eosio.cdt/bootcamp/EOS_Boot_Camp_New/existing_contracts/eosio.contracts/contracts/eosio.token/
cleos set contract carpool . --abi carpool.abi -p carpool@active

#Compile and deploy tradeticket
cd /workspace/EOS_Boot_Camp_New/our_contracts/tradeticket
eosio-cpp --abigen tradeticket.cpp -o tradeticket.wasm -I ../auction
cleos set contract tradeticket . --abi tradeticket.abi -p tradeticket@active


################################################################################
###############################Permission#######################################
################################################################################

##keep in mind that the following settings are just for the auction code as it is
#run first. When running other codes, the permission needs to be updated to the
#new contracts

#Add eosio.code permission for auction
cleos set account permission auction active --add-code

#Add eosio.code permission for carpool
leos set account permission carpool active --add-code

#Add eosio.code permission to auction's active permission for vtfootball (not 100% sure)
cleos set account permission vtfootball active \
'{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p vtfootball

#Add eosio.code permission to auction's active permission for ticket1
cleos set account permission ticket1 active \
'{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket1

#Add eosio.code permission to auction's active permission for ticket2
cleos set account permission ticket2 active \
'{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket2
