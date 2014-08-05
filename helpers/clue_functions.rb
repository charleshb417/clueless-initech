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
  #TO DO: figure out actual legal rooms/halls and such
  
  $legalRooms['Study'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Kitchen'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Hall'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Conservatory'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Lounge'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Ballroom'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Dining Room'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Library'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
  $legalRooms['Billiard Room'] = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room']
end

def createDeck
  
  cards = []
  
  #Initialize the values for each set of cards and shuffle them
  chars = ['Miss Scarlett', 'Colonel Mustard', 'Mrs. White', 'Mr. Green', 'Mrs. Peacock', 'Professor Plumb'].shuffle
  weapons = ['Candlestick', 'Wrench', 'Revolver', 'Knife', 'Rope', 'Lead Pipe'].shuffle
  rooms = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room'].shuffle

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
  
  send_message('start_game', msg) 
end

def add_user(user)
  $users[user] = {}
  $users.to_json
  
  msg = {}
  msg['user_update'] = $users
  
  send_message('user_update', msg)   
end

def remove_user(user)
  p "removing user " + user
  $users.delete(user)
  $users.to_json
  
  msg = {}
  msg['user_update'] = $users
  
  send_message('user_update', msg)  
  
  init_globals if $users.length == 0 #reset the service
end

def user_setup
  chars = ['Miss Scarlett', 'Colonel Mustard', 'Mrs. White', 'Mr. Green', 'Mrs. Peacock', 'Professor Plumb'].shuffle
  rooms = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room'].shuffle

  $users.each{ |key, user|
    $users[key]['character'] = chars[0]
    $users[key]['currentRoom'] = rooms[0]
    
    chars.delete(chars[0])
    rooms.delete(rooms[0])
  }
  
  $currentTurn = $users.keys[0] #current user's turn
end

def move_player(user, newRoom)
  currentRoom = $users[user]['currentRoom']
  playerCanMove = false
  if $legalRooms[currentRoom].include?(newRoom)
    $users[user]['currentRoom'] = newRoom
    playerCanMove = true
  end
  
  playerCanMove #return true or false
end


