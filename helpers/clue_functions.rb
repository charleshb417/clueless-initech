$guilty = {}
#$users = {'jovan'=>{}, 'jon'=>{}, 'charlie'=>{}}
$cardRef = {}

def createDeck
  
  cards = []
  
  #Initialize the values for each set of cards and shuffle them
  chars = ['Miss Scarlett', 'Colonel Mustard', 'Mrs. White', 'Mr. Green', 'Mrs. Peacock', 'Professor Plumb'].shuffle
  weapons = ['Candlestick', 'Wrench', 'Revolver', 'Knife', 'Rope', 'Lead Pipe'].shuffle
  rooms = ['Study', 'Kitchen', 'Hall', 'Conservatory', 'Lounge', 'Ballroom', 'Dining Room', 'Library', 'Billiard Room'].shuffle

  # Set the guilty cards and remove them from each "deck"
  $guilty = {"charachter"=>chars[0], "weapon"=>weapons[0], "room"=>rooms[0]}
  chars.delete(chars[0])
  weapons.delete(weapons[0])
  rooms.delete(rooms[0])

  # Organize the cards and make them pretty
  cards = chars + weapons + rooms
  
  $cardRef = {"charachters"=>chars, "weapons"=>weapons, "rooms"=>rooms}

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
  
end

