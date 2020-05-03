#!/bin/bash

#Create account
cleos create account eosio carpool EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

#Add the eosio.code permission to the contract's account's active permission
cleos set account permission carpool active --add-code
cleos set account permission weicheng active '{"threshold": 1,"keys": [{"key": "EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p weicheng
cleos set account permission aanuo active '{"threshold": 1,"keys": [{"key": "EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p aanuo
cleos set account permission zejia active '{"threshold": 1,"keys": [{"key": "EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p zejia

#Deploy the contract
cleos set contract carpool . --abi carpool.abi -p carpool@active
