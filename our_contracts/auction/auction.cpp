#include <eosio/eosio.hpp>
#include <eosio/asset.hpp>
#include <eosio/system.hpp>

#include <eosio/print.hpp>
#include <eosio/time.hpp>

#include "abieos_numeric.hpp"

//#include "/workspace/EOS_Boot_Camp_New/our_contracts/auction/eosio.token/include/eosio.token/eosio.token.hpp"
//#include "/workspace/EOS_Boot_Camp_New/our_contracts/auction/eosio.token/src/eosio.token.cpp"

#define VTOKEN symbol("VTOKEN", 0)
#define N 1  //# of winners (everytime it only allows 1 winner)
#define RAMCORE_SYMBOL symbol("RAMCORE", 4)
#define RAM_SYMBOL symbol("RAM", 0)

using namespace eosio;
using namespace std;


class [[eosio::contract("auction")]] auction : public eosio::contract
{




 private:

    /****************************************************************************
     *                                D A T A  T Y P E S
     ***************************************************************************/

    struct permission_level_weight {
       eosio::permission_level  permission;
       uint16_t          weight;

    };

    struct wait_weight {
       uint32_t           wait_sec;
       uint16_t           weight;

    };

   struct key_weight {
      abieos::public_key  key;
      uint16_t           weight;

   };

    struct authority {
       uint32_t                              threshold = 0;
       std::vector<key_weight>               keys;
       std::vector<permission_level_weight>  tickets;
       std::vector<wait_weight>              waits;

    };

    /****************************************************************************
     *                                T A B L E S
     ***************************************************************************/

    TABLE bid_order {
      name       ticket_for_bid;
      name       bider;
      asset      price_ask{0, VTOKEN};
      time_point time_stamp;

      uint64_t primary_key() const { return ticket_for_bid.value; }
    };


    typedef eosio::multi_index< "bidorders"_n, bid_order > bid_orders;
    bid_orders _bid_orders;


    /****************************************************************************
     *                            F U N C T I O N S
     ***************************************************************************/

    //time_point current_time_point() {
    //  const static time_point ct{ microseconds{ static_cast<eosio::time_point>( current_time_point() ) } };
    //  return ct;
    //}

    void create_bid_order( name  bider,
                            name  ticket_for_bid,
                            asset price_ask ) {
      /*bid_orders _bid_orders( _self, bider.value );*/
      check( _bid_orders.find( ticket_for_bid.value ) == _bid_orders.end(),
                    "you are already biding this ticket" );

      /* contract ticket pays for ram */
      auto order = _bid_orders.emplace( _self, [&]( auto& s ) {
        s.ticket_for_bid = ticket_for_bid;
        s.bider           = bider;
        s.price_ask        = price_ask;
        //s.time_stamp       = current_time_point();
      });
    }

  public:
    using contract::contract;

    // constructor
    auction( name receiver, name code, datastream<const char*> ds ):
                  contract( receiver, code, ds ),
                  _bid_orders( receiver, receiver.value )  {}






private:

  //Initialization of winner info
  int64_t winners_price[N] = {0};
  int64_t last_winner_price = {0};
  name winners[N];
  //name winners[N] = {name("VT")};
  
  /***Structured data types***/


  /***Tables***/
  struct [[eosio::table]] person
  {
    name user_name;
    asset funds;
    asset bid_price;
    //Use auxi_price to sort the table in desceding order
    uint64_t auxi_price;
    int64_t primary_key() const{ return user_name.value; };
    uint64_t get_price() const{ return bid_price.symbol.raw(); };
    uint64_t get_auxi() const{ return auxi_price; };
  };

  struct [[eosio::table]] ticket
  {
    name holder;
    name ticket;
    asset ticket_price;
    uint64_t price_value;

    int64_t primary_key() const{ return ticket.value; };
    //int64_t get_ticket() const{ return ticket.value; };
  };

  struct [[eosio::table]] account {
    asset balance;

    uint64_t primary_key()const { return balance.symbol.code().raw(); }
  };

  typedef eosio::multi_index<
    "people"_n, person, 
    indexed_by<"byprice"_n, const_mem_fun<person, uint64_t, &person::get_price>>,
    indexed_by<"byauxi"_n, const_mem_fun<person, uint64_t, &person::get_auxi>>
    > bid_index;

  typedef eosio::multi_index<
    "tickets"_n, ticket
    //indexed_by<"byticket"_n, const_mem_fun<ticket, int64_t, &ticket::get_ticket>>
    > ticket_index; 

public:
  //Calculate winners
  [[eosio::action]]
  void calwinners( )
  {

    bid_index _bid_records( get_self(), get_first_receiver().value) ;

    //Sort the list in descending order
    auto pridx = _bid_records.get_index<"byauxi"_n>();

    //Get the N best/highest bid prices
    uint64_t i = 0;
    for(auto& iterator : pridx)
    {
      if ( i<N )
      {
        winners_price[i] = iterator.bid_price.amount;
	//Update last winner price every time
	last_winner_price = winners_price[i];
	winners[i] = iterator.user_name;
	i++;
      }
      else
      {
	break;
      }
    }
  }

  //Places a bid
  [[eosio::action]]
  void placebid(name user, asset bid_price)
  {
    require_auth(user);

    auto sym = bid_price.symbol;

    check( bid_price.symbol == VTOKEN, "Symbol precision mismatch." );

    action(
      permission_level{get_self(),"active"_n},
      "eosio.token"_n,
      "checkbid"_n,
      std::make_tuple( user, bid_price )
    ).send();		    
    
    //Initialize the last winner price
    last_winner_price = 0;
    //Calculate the N top bid prices and bidders at present
    calwinners();

    //If the present bid price is too low, return 
    if( last_winner_price >= bid_price.amount )
    {
      //Need to bid 2 more dollars than the last_winner_price
      print("Sorry, your bid cannot be accepted. You need to bid at the price of ", last_winner_price + 2, " or higher. Thanks!");
      return;
    }

    bid_index _bid_records( get_self(), get_first_receiver().value) ;

    auto iterator = _bid_records.find(user.value);
    if ( iterator == _bid_records.end() )
    {
      _bid_records.emplace(user, [&]( auto& row ) {
	row.user_name = user;
	row.bid_price.amount = bid_price.amount;
        //limit the bid price to be less than 10000
	row.auxi_price = 10000-bid_price.amount;
      });
    }
    else
    {
      _bid_records.modify(iterator, user, [&]( auto& row ) {
	row.user_name = user;
	row.bid_price.amount = bid_price.amount;
        //limit the bid price to be less than 10000   
	row.auxi_price = 10000-bid_price.amount;
      });
    }

    
  }

  //update the onwership of a ticket if there is a trade
  [[eosio::action]]
  void updateticket(name user, name ticket_update, asset ticket_price)
  {
    ticket_index _ticket_records( get_self(), get_first_receiver().value) ;

    auto iterator = _ticket_records.find(ticket_update.value);
    if ( iterator == _ticket_records.end() )
    {
      //Not sure the first argument should be user or _self
      _ticket_records.emplace(_self, [&]( auto& row ) {
        row.holder = user;
        row.ticket = ticket_update;
        row.ticket_price = ticket_price;
	row.price_value = ticket_price.amount;
      });
    }
    else
    {
      _ticket_records.modify(iterator, _self, [&]( auto& row ) {
        row.holder = user;
        row.ticket = ticket_update;
        row.ticket_price = ticket_price;
	row.price_value = ticket_price.amount;
      });
    }
  }

  using updateticket_action = action_wrapper<"updateticket"_n, &auction::updateticket>;

 ACTION clearticket(   name ticket_to_clear,
                       std::string new_public_key, 
                       std::string stage) {
      require_auth( "vtfootball"_n );

      check( stage == "inseason",
                    "You can not in football season. You cannot trade your ticket" );

      check( is_account( ticket_to_clear ),
                    "ticket_for_bid does not exist");

      // find ticket for bid / bider / price
      auto order = _bid_orders.find( ticket_to_clear.value );

      check( order != _bid_orders.end(),
                    "could not find ticket for bid" );

      // order->bider sends money (price) to bider
      print( order->bider, " win the '", order->ticket_for_bid,
             " for ", order->price_ask, "\n" );

      action(
         permission_level{ order->bider, "active"_n },
         "eosio.token"_n,
         "transfer"_n,
         std::make_tuple(  order->bider,
                           "vtfootball"_n,
                          order->price_ask,
                          std::string("inseason") )
      ).send();

      action(
         permission_level{ order->ticket_for_bid, "active"_n },
         get_self(),
         "giveauth"_n,
         std::make_tuple( order->ticket_for_bid, new_public_key )
      ).send();

      auto user = order->bider;
      ticket_index _ticket_records( get_self(), get_first_receiver().value) ;

      //Store the ticket info for the bidding stage for searching purpose
      //As every ticket can be only sold once in the bidding stage, so maybe
      //we only use emplace here, as this clearticket cannot be executed again
      //if the ticket is not on the list
      //auto iterator = _ticket_records.find(ticket_to_clear.value);
      //if ( iterator == _ticket_records.end() )
      {
        _ticket_records.emplace(_self, [&]( auto& row ) {
          row.holder = user;
          row.ticket = order->ticket_for_bid;
          row.ticket_price = order->price_ask;
	  row.price_value = order->price_ask.amount;
        });
      }
      //else
      //{
      //  _ticket_records.modify(iterator, user, [&]( auto& row ) {
      //    row.holder = user;
      //    row.ticket = order->ticket_for_bid;
      //    row.ticket_price = order->price_ask;
      //  });
      //}

      _bid_orders.erase( order );

      //Delete all the info in the _bid_records, as the next bidding round will
      //start
      bid_index _bid_records( get_self(), get_first_receiver().value) ;

      auto it = _bid_records.begin();
      while(it != _bid_records.end())
      {
	it = _bid_records.erase(it);
      }

    }

    ACTION giveauth( const name user, const std::string new_owner_pubkey ) {
      // permission
      // parent
      // auth
      print("*** giveauth ***\n");
      std::array<uint8_t, 33> owner_pubkey_char;

      const std::string owner_key_str = new_owner_pubkey.substr(0, 53);
      print("new key: ", owner_key_str, "\n");

      // create new public key
      const abieos::public_key owner_pubkey =
            abieos::string_to_public_key( owner_key_str );

      std::copy( owner_pubkey.data.begin(),
                 owner_pubkey.data.end(),
                 owner_pubkey_char.begin() );

      // create new authority
      const auto owner_auth = authority{ 1,
        {
          {/*key_weight*/
            {abieos::key_type::k1, owner_pubkey_char}, 1
          }
        },
        {/*tickets*/},
        {/*waits*/}
      };

      // TODO: Change this from changing the "active" permission, to
      //       changing the "owner" permission!
      action(
         permission_level{ user, "active"_n },
         "eosio"_n,
         "updateauth"_n,
         std::make_tuple( user, "active"_n, "owner"_n, owner_auth)
      ).send();

    }



  //Print winners
  [[eosio::action]]
  void printwinners(name ticket_for_bid)
  {

    calwinners();

    for(auto i = 0; i != N; i++){
      print_f("{winner %}:{name: %, bid_price: %} | ", i+1, winners[i], winners_price[i]);
    }
      create_bid_order( winners[0], ticket_for_bid, {winners_price[0], VTOKEN} );
  }
  
  //Print all bid prices
  [[eosio::action]]
  void printbids(name user)
  {
    require_auth(user);

    bid_index _bid_records( get_self(), get_first_receiver().value) ;

    //Sort the list in descending order
    auto pridx = _bid_records.get_index<"byauxi"_n>();

    auto indx = 1;
    for(auto& iterator : pridx)
      print_f("{bidder %}:{name: %, bid_price: %} | ", indx++, iterator.user_name, iterator.bid_price.amount);
  }
};

EOSIO_DISPATCH(auction, (placebid)(printbids)(printwinners)(clearticket)(giveauth)(updateticket) )
