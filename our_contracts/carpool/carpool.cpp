#include <math.h>

#include <eosio/eosio.hpp>
#include <eosio/asset.hpp>
#include <eosio/system.hpp>
//#include <eosio.token/eosio.token.hpp>
#include <eosio/print.hpp>
#include <eosio/time.hpp>
//#include <eosiolib/public_key.hpp>

//#include "abieos_numeric.hpp"

#define VTOKEN symbol("VTOKEN", 0)
#define N 3  //# of winners (equal to the number of vailable football tickets for bidding. It can be changed as needed)

using namespace eosio;
using namespace std;

class [[eosio::contract("carpool")]] carpool: public eosio::contract {

    public:
        carpool(name receiver, name code, datastream<const char*> ds):
        contract(receiver, code, ds){}
        
        //Methods Declaration

        //Drivers Review.

        ACTION driverreview(){

        }

        //Passengers Review
        ACTION preview(){
            
        }

        ACTION login(name username){
            require_auth(username);
            users_table _users(get_self(), get_first_receiver().value);
            // Create a record in the table if the player doesn't exist in our app yet
            auto user_iterator = _users.find(username.value);
            if (user_iterator == _users.end()) {
                user_iterator = _users.emplace(username,  [&](auto& new_user) {
                new_user.username = username;
                });
            } 
        }

        //Add a Ride
        ACTION addpost(name user_name, string loc_desc, string post_title,string loc_param, uint64_t car_size, asset cost_trip){
            require_auth(user_name);
            carpool_index _cpool_index(get_self(), get_first_receiver().value);

            //You cannot do any check here
            _cpool_index.emplace(user_name, [&](auto& row){
                row.username = user_name;
                row.log_id = _cpool_index.available_primary_key();
                row.loc_desc = loc_desc;
                row.loc_param = loc_param;
                row.post_title = post_title;
                row.cost_jorn = cost_trip;
                row.car_space = car_size;
                row.delete_post = 0;
                
            });
            print("Trip Successfully Posted");
        }

        ACTION editpost(name username, uint64_t carpoolid, string post_title, string loc_desc, string loc_param, uint64_t car_size, asset cost_trip){
            //Edit Post Method
            require_auth(username);
            carpool_index _cpool_index(get_self(), get_first_receiver().value);
            auto itr = _cpool_index.find(carpoolid);

            if(itr != _cpool_index.end()){
                //It is my record. I can edit it
                _cpool_index.modify(itr, username, [&](auto& row){
                    row.loc_desc = loc_desc;
                    row.loc_param = loc_param;
                    row.car_space = car_size;
                    row.post_title = post_title;
                    row.cost_jorn = cost_trip;
                });
                print("Your post has been edited");
            }
            else{
                //This is not my record, deny access
                print("You cannot edit this record. It does not belong to you");
            }

        }

        ACTION deletepost(name username, uint64_t carpoolid){
            //Delete post Method. Set delete_post = 1
            carpool_index _cpool_index(get_self(), get_first_receiver().value);
            auto itr = _cpool_index.find(carpoolid);

            if(itr != _cpool_index.end()){
                _cpool_index.modify(itr, username, [&](auto& row){
                    row.delete_post = 1;
                });
            }
            else{
                print("Record does not exist");
            }
        }





        ACTION hopride(name username, uint64_t carpoolid, uint64_t space_req){
            //Join existing listing
            require_auth(username);
            joinride_index _joinride_index(get_self(), get_first_receiver().value);
            carpool_index _carpool_index(get_self(), get_first_receiver().value);           
            auto itr = _joinride_index.find(carpoolid);
            auto order = _carpool_index.find(carpoolid);

            //Check if the post exist in the db

            if(itr != _joinride_index.end()){
                //Check if the record is tied to the same user
                if(itr -> username != username){
                    //Different user posting. Insert
                     _joinride_index.emplace(username, [&](auto& row){
                        row.username = username;
                        row.jridx = _joinride_index.available_primary_key();
                        row.carpoolid = carpoolid;
                        row.size_req = space_req;


                    });
                    
                    action(
                        permission_level{ username, "active"_n },
                        "eosio.token"_n,
                        "transfer"_n,
                        std::make_tuple( username,
                                        order->username,
                                        order->cost_jorn ,
                                     std::string("inseason"))
                    ).send();

                    action(
                        permission_level{ get_self(), "active"_n },
                        get_self(),
                        "deletepost"_n,
                        std::make_tuple( order->username, order->log_id)
                    ).send();

                    print("You have signup for this ride");
    
                }
                else{
                    //Same user posting. Tell person to use the edit or cancel button
                    print("You have already signed up for this post! Do you want to edit?");
                }
            }
            else{
                //It means nobody has signed up for the trip. Insert the record fast
                _joinride_index.emplace(username, [&](auto& row){
                    row.username = username;
                    row.jridx = _joinride_index.available_primary_key();
                    row.carpoolid = carpoolid;
                    row.size_req = space_req;
                });
                
                action(
                    permission_level{ username, "active"_n },
                    "eosio.token"_n,
                    "transfer"_n,
                    std::make_tuple( username,
                                    order->username,
                                    order->cost_jorn ,
                          std::string("inseason"))
                ).send();

                action(
                    permission_level{ get_self(), "active"_n },
                    get_self(),
                    "deletepost"_n,
                    std::make_tuple( order->username, order->log_id)
                ).send();

                print("You have signup for this ride");
            }

        }

    
    //Database Declaration
    private:

        TABLE carpoolog{

            name username;
            uint64_t log_id;
            uint64_t car_space;
            string loc_desc;
            string loc_param;
            asset  cost_jorn{0, VTOKEN};
            string post_title;
            uint64_t delete_post;

            auto primary_key() const {return log_id;}
	    //Here I can only use uint64_t, not sure of why
            uint64_t by_username() const {return username.value;}
        };
        typedef multi_index <
	  "carpool"_n, carpoolog,
	  indexed_by<"byname"_n, const_mem_fun<carpoolog, uint64_t, &carpoolog::by_username>>
          > carpool_index;

        TABLE joinride{

            name username;
            uint64_t jridx;
            uint64_t carpoolid;
            uint64_t size_req;

            auto primary_key() const {return jridx;}
            uint64_t by_username() const {return username.value;}
        };
        typedef multi_index <
	  "joinrt"_n, joinride,
	  indexed_by<"byname"_n, const_mem_fun<joinride, uint64_t, &joinride::by_username>>
	  > joinride_index;

        TABLE user_info {
        name            username;
        uint16_t        win_count = 0;
        uint16_t        lost_count = 0;

        auto primary_key() const { return username.value; }
        };
        typedef eosio::multi_index<name("users"), user_info> users_table;

        TABLE ticket_info{
            name ticketname;

            auto primary_key() const {return ticketname.value;}
        };
        typedef eosio::multi_index<name("ticketinfo"), ticket_info>ticket_table;

};
EOSIO_DISPATCH( carpool, (addpost)(editpost)(deletepost)(hopride) )
