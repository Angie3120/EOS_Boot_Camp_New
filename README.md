# VTRADE (A Token-based Blockchain System for Football Ticket Bidding and Trading at Virginia Tech)
This is the repo for the VTrade team (Weicheng Xue, Zejia Jing and Aanuoluwapo Ojelade) in the 2020 EOS Boot Camp. This repo is aimed to:

1. Setting up a bidding system for the football ticket sales in the beginning of a season (strictly a game, but it can be extended to multiple games).
2. Setting up a carpool system for the shared rides between strangers. This can help solve the traffic conjestion issue on a game day.
3. Setting up an incentivised ticket trading system for the ticket sales among the VT community members. VT can get a small revenue every time when a deal occurs.

Creation Date: 04/09/2020

Judges could ignore any changes after Apr. 24th for competition purpose, as the changes made after Apr. 2th are mainly polishing the code and showing the demo better. However, these changes are to make the Dapp better and more real life like. The competition is not an end but just a beginning, as we all are interested in blockchain. Thanks!

# Background
As is known, Hokies need to share public resources (football tickets, parking spaces, etc.) in the university due to resource limitations. If students want to sell or buy football tickets, they usually resolve it through eBay, Facebook or scalpers. Such middlemen or platforms get a high cut of revenue without tickets authenticity inspection and may leak personal information such as Facebook. Hokie community has been relying on these unsecured centralized ticket servers for many years. Thus, a token-based EOSIO framework (using smart contracts) based on HokieChain will be designed to facilitate the football ticket marketplace and the game transportations. The blockchain platform will enable the VT community to (1) bid the football tickets at the beginning of a season via token-based deposits and contracts,  (2) trade the tickets during the season, (3) track the ownership flow to guarantee the ticket authenticity, (4) lease or rent the parking and carpool spaces using reputation-based statistics. A small fee will be back to VT football every time tickets change hands. Besides, ticket sellers can make money and buyers can exchange for preferable game and seats. In this way, both VT and participants will be benefited and encouraged. We believe the blockchain platform can greatly benefit the VT community in tickets allocation efficiency, intermediary exchange cost, transparency, authenticity, and game transportation convenience and clean.

# Code Description

## Our Contracts

### auction
This contract is the contract for the ticket bidding in the begining of a game. It has multiple multi-index tables, including holder_records and bid_records. It also has multiple actoins, including placebid, buyticket and giveauth. It inliens external contract actions such as eosio.token "transfer" and "checkbid", which is an user-defined action, and eosio "updateauth". 

### carpool
This contract is the contract for carpooling. It also has multiple multi-index tables, including carpoolog and joinride. Actions such as addpost, editpost and hopride are included.

### tradetickt
This contract is the contract for trading tickets in-seasonal. It has sell_order and buy_order tables. Important actions include sellticket and buyticket and giveauth. Buyticket inlines to the eosio.token "transfer" and intra-code "giveauth" actions. Giveauth inlines to the eosio "updateauth" actions.

### Frontend
This is the link to the frontend. https://github.com/weich97/EOS_Boot_Camp_frontend
