#!/bin/bash

cleos push action carpool login '["weicheng"]' -p weicheng@active
cleos push action carpool login '["aanuo"]' -p aanuo@active
cleos push action carpool login '["zejia"]' -p zejia@active

echo "Initial post"
cleos push action carpool addpost '["aanuo", "VT sports center", "5 mins to the court", "1111",4, "5 VTOKEN"]' -p aanuo@active
cleos get table carpool carpool carpool
echo "Update post due to traffic conjestion."
cleos push action carpool editpost '["aanuo", 0, "10 mins to the court", "VT sports center","1111",4, "5 VTOKEN"]' -p aanuo@active

cleos get table carpool carpool carpool
echo "Zejia see the post 0 and want to buy the carpool space."
cleos push action carpool hopride '["zejia", 0, 4]' -p zejia@active


echo "Token balance of zejia and aanuo change"
cleos get currency balance eosio.token zejia VTOKEN
cleos get currency balance eosio.token aanuo VTOKEN
echo "The carpool message of logid 00 is removed from the list"
cleos get table carpool carpool carpool
cleos get table carpool carpool joinrt