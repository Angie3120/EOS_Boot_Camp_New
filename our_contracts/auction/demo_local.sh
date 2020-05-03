#!/bin/bash


################################################################################
###############################Eosio.token######################################
################################################################################

echo "Begin issuing tokens"

#Create, issue and transfer tokens
cleos push action eosio.token create '[ "vtfootball", "1000000000 VTOKEN"]' -p eosio.token@active
cleos push action eosio.token issue '[ "vtfootball", "100000000 VTOKEN", "Initial Token Offering" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "weicheng", "200 VTOKEN", "Send 200 VTOKEN to Weicheng" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "zejia", "200 VTOKEN", "Send 200 VTOKEN to Zejia" ]' -p vtfootball@active
cleos push action eosio.token transfer '[ "vtfootball", "aanuo", "200 VTOKEN", "Send 200 VTOKEN to Aanuo" ]' -p vtfootball@active


################################################################################
#################################Auction########################################
################################################################################

echo "Begin auction ticket1"

#placebid first checks the balance, then calculates the present highest bid price,
#and finally writes the bid into the people table, if eligible
cleos push action auction placebid '["zejia", "10 VTOKEN"]' -p zejia@active
cleos push action auction placebid '["aanuo",  "12 VTOKEN"]' -p aanuo@active
cleos push action auction placebid '["weicheng", "14 VTOKEN"]' -p weicheng@active

#printwinner creates the bid order for the winner. The bidorders table stores the
#bid order info. of the winner
cleos push action auction printwinners '["ticket1"]' -p auction@active

#it first charges the winner some tokens (transfer to vtfootball), then gives the
#authority of the ticket to the winner, then stores the winner info in the tickets
#table, and finally erase the bidorders and people table. The key here is the public
#key of the winner's public key (the key of the ticket is also changed here)
cleos push action auction clearticket '["ticket1","EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","inseason"]' -p vtfootball

#it shows the trade is sucessfully set
cleos get currency balance eosio.token weicheng VTOKEN
cleos get account ticket1


################################################################################
##################################Carpool#######################################
################################################################################

##Now we need to add eosio.code permission to carpool's active permission for
#some accounts which push actions here
cleos set account permission zejia active '{"threshold": 1,"keys": [{"key": "EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p zejia
cleos set account permission aanuo active '{"threshold": 1,"keys": [{"key": "EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p aanuo
cleos set account permission weicheng active '{"threshold": 1,"keys": [{"key": "EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","weight": 1}],"accounts": [{"permission":{"actor":"carpool","permission":"eosio.code"},"weight":1}]}' owner -p weicheng

#login. Use users table to check
cleos push action carpool login '["weicheng"]' -p weicheng@active
cleos push action carpool login '["aanuo"]' -p aanuo@active
cleos push action carpool login '["zejia"]' -p zejia@active

##posting, editing and checking

#Use carpool table to check
cleos push action carpool addpost '["aanuo", "VT sports center", "5 mins to the court", "1111",4, "5 VTOKEN"]' -p aanuo@active
cleos push action carpool editpost '["aanuo", 0, "10 mins to the court", "VT sports center","1111",4, "5 VTOKEN"]' -p aanuo@active

#Use joinrt table to check
cleos get table carpool carpool carpool

#rider wants a ride. It first writes an entry in the joinrt table, then transfer
#some tokens from the rider's account to the rider's account, then deletes the
#relevant entry in the carpool table (I may misss something here)
cleos push action carpool hopride '["zejia", 0, 4]' -p zejia@active

#check the balance and the table to see whether it is successfully traded
cleos get currency balance eosio.token zejia VTOKEN
cleos get currency balance eosio.token aanuo VTOKEN
cleos get table carpool carpool carpool
cleos get table carpool carpool joinrt


################################################################################
###############################Tradeticket######################################
################################################################################

echo "Begin trading tickets"

##Now we need to add eosio.code permission to tradeticket's active permission for
#some accounts which have trade actions here

#add eosio.code to tradeticket's active permission for ticket1
cleos set account permission ticket1 active \
'{"threshold": 1,"keys": [{"key": "EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p ticket1

#add eosio.code to tradeticket's active permission for users
cleos set account permission zejia active \
'{"threshold": 1,"keys": [{"key": "EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p zejia
cleos set account permission aanuo active \
'{"threshold": 1,"keys": [{"key": "EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p aanuo
cleos set account permission weicheng active \
'{"threshold": 1,"keys": [{"key": "EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","weight": 1}],"accounts": [{"permission":{"actor":"tradeticket","permission":"eosio.code"},"weight":1}]}' \
owner -p weicheng

#it creates an sell entry in the sellorders table
cleos push action tradeticket sellticket '["weicheng","ticket1","20 VTOKEN","inseason"]' -p ticket1

#checks the sellorders table
cleos get table tradeticket tradeticket sellorders

#it first finds an order from the sellorders table, then transfer the tokens to 
#the seller's account, with 2 tokens transferred to vtfooball as revenues, then
#it adds the revenue to the total revenues vtfootball gets and updates it in the
#revenues table, then it updates the tickets table in the auction contract to
#reflect the change of the ownersihp of the ticket, and finally it erases the
#ticket in the sellorders table. Here the key belongs to the buyer
cleos push action tradeticket buyticket '["aanuo","ticket1","EOS5wNaiDJqWBFGYS4RB5nks7ZYf72przz2QPcHz46kJrEvccfGZZ","inseason"]' -p aanuo

##We will have more transactions

#2nd round
cleos push action tradeticket sellticket '["aanuo","ticket1","25 VTOKEN","inseason"]' -p ticket1
cleos push action tradeticket buyticket '["zejia","ticket1","EOS8548cE8JioJT9ZRRdPqQ3KR6QmN6fH5ssE2ULKiBfbrmz7uYnX","inseason"]' -p zejia

#3rd round
cleos push action tradeticket sellticket '["zejia","ticket1","32 VTOKEN","inseason"]' -p ticket1
cleos push action tradeticket buyticket '["weicheng","ticket1","EOS7nXVLLrEda6Xr8FG3hxyc47LsC19Us9avhUK3uEPiPghdJPG2c","inseason"]' -p weicheng

#buyorders can be used to track the history price of any ticket
cleos get table tradeticket tradeticket buyorders

#it shows the key of ticket1 is changed again
cleos get account ticket1

#it shows the balance of all students
cleos get currency balance eosio.token weicheng VTOKEN
cleos get currency balance eosio.token zejia VTOKEN
cleos get currency balance eosio.token aanuo VTOKEN

#it shows the ownership of any tickets.
cleos get table auction auction tickets

#it displays the total revenue vtfootball gets
cleos get table tradeticket tradeticket revenues
