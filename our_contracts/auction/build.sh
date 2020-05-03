#!/bin/bash
cd /workspace/EOS_Boot_Camp_New/our_contracts/auction

#Compile auction
eosio-cpp --abigen auction.cpp -o auction.wasm

cd /workspace/EOS_Boot_Camp_New/our_contracts/tradeticket

#Compile auction
eosio-cpp --abigen tradeticket.cpp -o tradeticket.wasm -I ../auction

cd /workspace/EOS_Boot_Camp_New/our_contracts/auction

#Create account
cleos create account eosio auction EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio tradeticket EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
cleos create account eosio ticket1 EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7
cleos create account eosio ticket2 EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7
cleos create account eosio weicheng EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c
cleos create account eosio zejia EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX
cleos create account eosio aanuo EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ
cleos create account eosio alice EOS6s3BxLMpa14syK4oHDsvGxHT8p7LjBz1e5VzstXFAviqipfo2G
cleos create account eosio bob EOS53VzahSZQUqKcmvJVj59RYTV9q8JB2L6U4z39fRVNJ2mjLJVZ3

#!/bin/bash

cd /workspace/EOS_Boot_Camp_New/existing_contracts/eosio.contracts/contracts/eosio.token
cleos create account eosio eosio.token EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
eosio-cpp -I include -o eosio.token.wasm src/eosio.token.cpp --abigen
cleos set contract eosio.token . --abi eosio.token.abi -p eosio.token@active
cleos push action eosio.token create '[ "vtfootball", "1000000000 VTOKEN"]' -p eosio.token@active
cleos create account eosio vtfootball EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7
cleos push action eosio.token issue '[ "vtfootball", "100000000 VTOKEN", "Initial Token Offering" ]' -p vtfootball@active

cleos push action eosio.token transfer '[ "vtfootball", "weicheng", "200 VTOKEN", "Send 200 VTOKEN to Weicheng" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "zejia", "200 VTOKEN", "Send 200 VTOKEN to Zejia" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "aanuo", "200 VTOKEN", "Send 200 VTOKEN to Aanuo" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "alice", "200 VTOKEN", "Send 200 VTOKEN to alice" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "bob", "200 VTOKEN", "Send 200 VTOKEN to bob" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "ticket1", "10 VTOKEN", "m" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "ticket2", "10 VTOKEN", "m" ]' -p vtfootball@active

#Show balance
cleos get currency balance eosio.token weicheng VTOKEN
cleos get currency balance eosio.token aanuo VTOKEN
cleos get currency balance eosio.token zejia VTOKEN
cleos get currency balance eosio.token alice VTOKEN
cleos get currency balance eosio.token bob VTOKEN

cd /workspace/EOS_Boot_Camp_New/our_contracts/auction


cleos set account permission auction active --add-code
cleos set account permission weicheng active '{"threshold": 1,"keys": [{"key": "EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' owner -p weicheng
cleos set account permission aanuo active '{"threshold": 1,"keys": [{"key": "EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' owner -p aanuo
cleos set account permission zejia active '{"threshold": 1,"keys": [{"key": "EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' owner -p zejia
cleos set account permission alice active '{"threshold": 1,"keys": [{"key": "EOS6s3BxLMpa14syK4oHDsvGxHT8p7LjBz1e5VzstXFAviqipfo2G","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' owner -p alice
cleos set account permission bob active '{"threshold": 1,"keys": [{"key": "EOS53VzahSZQUqKcmvJVj59RYTV9q8JB2L6U4z39fRVNJ2mjLJVZ3","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' owner -p bob


echo "add auction@eosio.code permission to ticket1@active"
 cleos set account permission ticket1 active \
 '{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket1

echo "add auction@eosio.code permission to ticket1@active"
 cleos set account permission ticket2 active \
 '{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket2


echo "=== add auction@eosio.code permission to vtfootball@active ==="
cleos set account permission vtfootball active \
'{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p vtfootball


#Deploy the contract 
cleos set contract auction . --abi auction.abi -p auction@active

cd /workspace/EOS_Boot_Camp_New/our_contracts/tradeticket
#Deploy the contract 
cleos set contract tradeticket . --abi tradeticket.abi -p tradeticket@active

cd /workspace/EOS_Boot_Camp_New/our_contracts/auction
