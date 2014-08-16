def init_globals
  $users = {}
  $guilty = {}
  $cardRef = {}
  $legalRooms = {}
end

def send_message(event, msg)
    msg['event'] = event
    msg = msg.to_json
    $clients.each do |socket|
      socket.send msg
    end
end

def notify_players(playerList, note)
  msg = {}
  msg['notify_players'] = playerList
  msg['notify_message'] = note
  send_message('notification', msg)
end
  
def setLegalRooms
  
  #Rooms
  $legalRooms['study'] = ['studyhall', 'studylibrary', 'kitchen']
  $legalRooms['kitchen'] = ['ballroomkitchen', 'diningkitchen', 'study']
  $legalRooms['hall'] = ['studyhall', 'halllounge', 'hallbilliard']
  $legalRooms['conservatory'] = ['libraryconservatory', 'conservatoryballroom', 'lounge']
  $legalRooms['lounge'] = ['halllounge', 'loungedining', 'conservatory']
  $legalRooms['ballroom'] = ['conservatoryballroom', 'billiardballroom', 'ballroomkitchen']
  $legalRooms['dining'] = ['diningkitchen', 'billiarddining', 'loungedining']
  $legalRooms['library'] = ['studylibrary', 'libraryconservatory', 'librarybilliard']
  $legalRooms['billiard'] = ['librarybilliard', 'hallbilliard', 'billiarddining', 'billiardballroom']

  # Halls
  $legalRooms['studyhall'] = ['study', 'hall']
  $legalRooms['halllounge'] = ['hall', 'lounge']
  $legalRooms['librarybilliard'] = ['library', 'billiard']
  $legalRooms['billiarddining'] = ['billiard', 'dining']
  $legalRooms['conservatoryballroom'] = ['conservatory', 'ballroom']
  $legalRooms['ballroomkitchen'] = ['ballroom', 'kitchen']
  $legalRooms['studylibrary'] = ['study', 'library']
  $legalRooms['libraryconservatory'] = ['library', 'conservatory']
  $legalRooms['hallbilliard'] = ['hall', 'billiard']
  $legalRooms['billiardballroom'] = ['billiard', 'ballroom']
  $legalRooms['loungedining'] = ['lounge', 'dining']
  $legalRooms['diningkitchen'] = ['dining', 'kitchen']
 
end

def createDeck
  
  cards = []
  
  #Initialize the values for each set of cards and shuffle them
  chars = ['Miss Scarlet', 'Colonel Mustard', 'Mrs. White', 'Mr. Green', 'Mrs. Peacock', 'Professor Plum'].shuffle
  weapons = ['Candlestick', 'Wrench', 'Revolver', 'Knife', 'Rope', 'Lead Pipe'].shuffle
  rooms = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining', 'Library', 'Billiard'].shuffle

  # Set the guilty cards and remove them from each "deck"
  $guilty = {"character"=>chars[0], "weapon"=>weapons[0], "room"=>rooms[0]}
  chars.delete(chars[0])
  weapons.delete(weapons[0])
  rooms.delete(rooms[0])

  # Organize the cards and make them pretty
  cards = chars + weapons + rooms
  
  $cardRef = {"characters"=>chars, "weapons"=>weapons, "rooms"=>rooms}

  cards.shuffle #return cards (shuffled)
end

def dealCards(cards)
  cardsPer = (cards.length / $users.length).floor
   
  $users.each{ |key, user|
    $users[key]['cards'] = cards[0..cardsPer-1]
    cards[0..cardsPer-1].each{|card| cards.delete(card)}
  }

  if cards.length > 0
    while cards.length != 0
      $users.each{ |key, user|
        $users[key]['cards'].push(cards[0]) if cards[0]
        cards.delete(cards[0])
      }  
    end
  end

  user_setup #give each user a character and current room value
  msg = {}
  msg['start_game'] = $users
  msg['users_list'] = $users.keys
  msg['user'] = $users[$users.keys[0]]['character']
  msg['move_reply'] = false
  p msg['user']
  send_message('start_game', msg) 
end

def add_user(user)
  $users[user] = {}
  $users.to_json
  
  msg = {}
  msg['user_update'] = $users
  msg['users_list'] = $users.keys
  
  send_message('user_update', msg)   
end

def remove_user(user)
  p "removing user " + user
  $users.delete(user)
  $users.to_json
  
  msg = {}
  msg['user_update'] = $users
  msg['users_list'] = $users.keys

  send_message('user_update', msg)  
  
  init_globals if $users.length == 0 #reset the service
end

def user_setup
  chars = ['Colonel Mustard', 'Mrs. White', 'Mr. Green', 'Mrs. Peacock', 'Professor Plum'].shuffle
  char_rooms = {'Miss Scarlet'=>'HallLounge', 'Colonel Mustard'=>'LoungeDining', 'Mrs. White'=>'BallroomKitchen', 'Mr. Green'=>'ConservatoryBallroom', 'Mrs. Peacock'=>'LibraryConservatory', 'Professor Plum'=>'StudyLibrary'}

  chars.unshift('Miss Scarlet')
  $users.each{ |key, user|
    $users[key]['character'] = chars[0]
    $users[key]['currentRoom'] = char_rooms[chars[0]]
    
    chars.delete(chars[0])
  }
  
  $currentTurn = $users.keys[0] #current user's turn
end

def move_player(user, newRoom)
  currentRoom = $users[user]['currentRoom']
  playerCanMove = false
  if $legalRooms[currentRoom.downcase].include?(newRoom.downcase)
    $users[user]['currentRoom'] = newRoom
    playerCanMove = true
  end
  
  playerCanMove #return true or false
end


