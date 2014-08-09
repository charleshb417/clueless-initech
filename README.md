clueless-initech
================

Repository for Team Initech's Software Engineering project Clueless.

The server is expecting JSON to be sent to it. You can create these as objects in JAVA and convert them to JSON quite easily, 
then send the message to the websocket address. I plan on putting this up on Amazon soon so it will be much easier to test.

The basic JSON structure of a message would look something like this: 
{"event":"event_name", "variable name":"variable value"}

How this document is structured:
I) Scenario Name - Description of what scenario does
a) Receive Message - The message that this server is expecting to receive
b) Send Message - The message that will be sent to the client, if anything. This message is JSON text that would be parsed 
  on the Java client side.
  
1) Adding a user - Add a user to the session.
a) Receive Message- {"event":"add_user", "username":"user"}
b) Send Message- {"event":"user_update", "user_update":a hash of users*}

2) Remove a user - Remove a user from the session. Unlikely this will be used for the presentation
a) Receive Message- {"event":"remove_user", "username":"user"}
b) Send Message- {"event":"user_update", "user_update":a hash of users}

3) Deal the cards - Server will deal cards and return each user object with what cards they have. Signifies game beginning
a) Receive Message- {"event":"deal"}
b) Send Message- {"event":"start_game", "start_game":a hash of users with a 'cards' key for each user}

4) Move a player - Server will handle what location all users are at
a) Receive Message- {"event":"move", "user":user ,"newRoom":"room to move to"}
b) Send Message- {"event":"player_move", "user":"user to move", "move_reply":"a boolean true false if the player can move", "user_obj":users hash with updated rooms}

5) Switch the player's turn - Server will handle who's turn it is and return it to the users. Client will tell Server to switch turn by invoking this
a) Receive Message- {"event":"turn_switch"}
b) Send Message- {"event":"new_turn", "new_turn":"user"}

6) Suggestion - Player make's a suggestion
a) Receive Message- {"event":"suggestion", "user":"user1", "character":"character", "weapon":"weapon", "room":"room"}
b) Send Message- {"event":"suggestion_made", "suggestion_made":{"charachter":"Char", "weapon":"Weapon", "room":"room"}, "user":"User1"}

7) Disprove a suggestion
a) Receive Message- {"event":"suggestion", "disprover":"User1", "disprovee":"player who made suggestion", "character":"character","weapon":"weapon","room":"room", "disproveItem":"item"}
b) Send Message- {"event":"disprove", "is_disproved":boolean, "disprover":"User1", "disprovee":"player who made suggestion"}

8) Accusation - Player make's an accusation and the server determines if correct
a) Receive Message- {"event":"accusation", "character":"character", "weapon":"weapon", "room":"room", "user":"user making accusation"}
b) Send Message- {"event":"accusation_result", "accusation_result":"boolean if right or not", "answer":a hash of guilty cards**, "user":"user making accusation"}

9) Notification - Client sends a notification to the server
a) Receive Message- {"event":"notify", "playerList":["player1", "player2"], "note":"This is a note"}
b) Send Message- {"event":"notification", "notify_players":["player1", "player2"], "notify_message":"This is a note"}

10) Reset Character List - Reset character list to easily get cards, player locations, etc.
a) Receive Message- {"event":"get_users"}
b) Send Message- {"event":"reset", "user_update":a hash of users*}

* Character Hash- Not completely designed yet but contains all user information. More details next commit
** Guilty hash- {"character":"character","weapon":"weapon","room":"room"}


Legal Rooms (Names appear as they do in the code)

  <Rooms>
  Study = StudyHall, StudyLibrary
  Kitchen = BallroomKitchen, DiningKitchen
  Hall = StudyHall, HallLounge, HallBilliard
  Conservatory = LibraryConservatory, ConservatoryBallroom
  Lounge = HallLounge, LoungeDining
  Ballroom = ConservatoryBallroom, BilliardBallroom, BallroomKitchen
  Dining = DiningKitchen, BilliardDining, LoungeDining
  Library = StudyLibrary, LibraryConservatory, LibraryBilliard
  Billiard = LibraryBilliard, HallBilliard, BilliardDining, BilliardBallroom

  <Halls>
  StudyHall = Study, Hall
  HallLounge = Hall, Lounge
  LibraryBilliard = Library, Billiard
  BilliardDining = Billiard, Dining
  ConservatoryBallroom = Conservatory, Ballroom
  BallroomKitchen = Ballroom, Kitchen
  StudyLibrary = Study, Library
  LibraryConservatory = Library, Conservatory
  HallBilliard = Hall, Billiard
  BilliardBallroom = Billiard, Ballroom
  LoungeDining = Lounge, Dining
  DiningKitchen = Dining, Kitchen
