cd /workspace/EOS_Boot_Camp_New/our_contracts/auction

#Compile auction
eosio-cpp --abigen auction.cpp -o auction.wasm

cd /workspace/EOS_Boot_Camp_New/our_contracts/tradeticket

#Compile auction
eosio-cpp --abigen tradeticket.cpp -o tradeticket.wasm

cd /workspace/EOS_Boot_Camp_New/our_contracts/auction

#Deploy the contract 
cleos set contract auction . --abi auction.abi -p auction@active

cd /workspace/EOS_Boot_Camp_New/our_contracts/tradeticket
#Deploy the contract 
cleos set contract tradeticket . --abi tradeticket.abi -p tradeticket@active

cd /workspace/EOS_Boot_Camp_New/our_contracts/auction

cleos create account eosio ticket4 EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7

cleos push action eosio.token transfer '[ "vtfootball", "ticket4", "10 VTOKEN", "m" ]' -p vtfootball@active

 cleos set account permission ticket4 active \
 '{"threshold": 1,"keys": [{"key": "EOS7dJcV4RBZ9YBrQuMwCSSu1RYt1r2TFdrHUXpA7EVzyv6yj6Wg7","weight": 1}],"accounts": [{"permission":{"actor":"auction","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket4

cleos push action auction printwinners '["ticket4"]' -p auction@active

cleos set account permission ticket4 active \
'{"threshold": 1,"keys": [{"key": "EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket4

cleos set account permission aanuo active \
'{"threshold": 1,"keys": [{"key": "EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p aanuo

cleos push action tradeticket sellticket '["zejia","ticket4","80 VTOKEN","inseason"]' -p ticket4

cleos push action tradeticket buyticket '["aanuo","ticket4","EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","inseason"]' -p aanuo
