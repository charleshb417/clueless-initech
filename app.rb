require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'json'
require './helpers/clue_functions'

init_globals

EM.run do
  class App < Sinatra::Base
    set :bind, '0.0.0.0'
    
    get '/' do
      erb :index
    end
    
    get '/remove_user' do
      user = params[:user]
      remove_user(user)
    end
    
    get '/reset' do
      # TO DO : SEND MESSAGE BEFORE CLEARING GLOBALS
      
      init_globals
      p "Game reset."
    end
  end

  $clients = []
  

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    
    ws.onopen do |handshake|
      $clients << ws
    end

    ws.onclose do
      $clients.delete ws
    end

    ws.onmessage do |msg|
      begin 

      # parse the message. Message will say stuff like "player moved", "deal cards", "suggestion made"
      message = JSON.parse(msg)
      p message
      if message.include?('event')
        case message['event']
        when "add_user"
          
          add_user(message['username'])
          
        when "remove_user"
          
          remove_user(message['username'])
          
        when "deal"
          #deal cards and create guilty triple
          setLegalRooms
          dealCards(createDeck)
          
        when "move"
          user = message['user']
          newRoom = message['newRoom']
          canMove = move_player(user, newRoom)
          msg = {}
          msg['user'] = user
          msg['move_reply'] = canMove
          msg['user_obj'] = $users
          
          send_message('player_move', msg)   
             
        when "turn_switch"
          players = $users.keys
          tmpTurn = $currentTurn
          
          indexVal = players.index(tmpTurn) + 1
          indexVal = 0 if indexVal >= players.length

          $currentTurn = players[indexVal]
          msg = {}
          msg['new_turn'] = $currentTurn
          msg['character'] = $users[$currentTurn]['character']
          p msg
          send_message('new_turn', msg)   
             
        when "suggestion"
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          
          players = $users.keys
          indexVal = players.index($currentTurn) + 1
          indexVal = 0 if indexVal >= players.length
          
          msg = {}
          msg['suggestion_made'] = {"character"=>gChar, "weapon"=>gWeap, "room"=>gRoom}
          msg['user'] = message['user']
          msg['first_disprover'] = players[indexVal]
          
          send_message('suggestion', msg)
          
          ## Move suggested player
          $users.each{ |key, usr|
            if usr['character'] == gChar
            
              user = key
              newRoom = usr['currentRoom']
              msg = {}
              msg['user'] = user
              msg['move_reply'] = true
              msg['user_obj'] = $users
          
              send_message('player_move', msg)        
            end
          }
                 
        when "disprove"

          item = message['disproveItem']
          disprover = message['disproover']
          players = $users.keys
 
          if item != "false"
            note = disprover + " has disproved the suggestion with the " + item + " card."
            returnVal = "false"
          else
            indexVal = players.index(disprover) + 1
            indexVal = 0 if indexVal >= players.length
            if players[indexVal] != $currentTurn
              note = disprover + " was not able to disprove the suggestion. It is now " + players[indexVal] + "'s turn to disprove."
              returnVal = players[indexVal]
            else
              note = disprover + " was not able to disprove the suggestion. Nobody was able to disprove."
              returnVal = "false"
            end
          end
          
          #notify client of who's turn to disprove it is
          notify_players(players, note)
          msg = {'next_turn'=>returnVal}
          send_message('disprove_reply', msg)
          
        when "accusation"
          
          gChar = message['character']
          gWeap = message['weapon']
          gRoom = message['room']
          user = message['user']
          
          didWin = false
          if $guilty['character'].downcase == gChar.downcase && $guilty['weapon'].downcase == gWeap.downcase && $guilty['room'].downcase == gRoom.downcase
            didWin = true
          end
          
          msg = {}
          msg['accusation_result'] = didWin
          msg['accusation_made'] = {"character"=>gChar, "weapon"=>gWeap, "room"=>gRoom}
          msg['answer'] = $guilty
          msg['user'] = user
          
          send_message('accusation_result', msg)
        
        when "notify"
          note = message['note']
          playerList = message['playerList']
          notify_players(playerList, note)
        
        when "get_users"
          msg = {}
          msg["user_update"] = $users
          msg['users_list'] = $users.keys

          send_message('user_list', msg)
        
        else
          p "Uhh..."
        end
      end
      rescue
        p "There has been an error."
      end
    end
  end

  App.run! :port => 3000
end
