      var socket, host, message;
      host = "ws://localhost:3001";

      function connect() {
        try {
          socket = new WebSocket(host);


          socket.onopen = function() {
        	  
          }

          socket.onclose = function() {

          }

          socket.onmessage = function(msg) {
        	  message = JSON.parse(msg.data);
        	  console.log(message);
        	  if (message['event'] == 'user_update'){
        		  fillWaitingRoom(message['user_update']);
        	  }
        	  if (message['event'] == 'reset'){
        		  fillWaitingRoom(message['user_update']);
        	  }
        	  if (message['event'] == 'start_game'){
        		  startGame(message['start_game']);
        	  }
        	  if (message['event'] == 'player_move'){
        		  alert (message['move_reply']);
        	  }
        	  if (message['event'] == 'new_turn'){
        		  alert (message['new_turn']);
        	  }
        	  if (message['event'] == 'accusation_result'){
        		  alert (message['accusation_result']);
        		  var ans = message['answer']['character'] + " with the " + message['answer']['weapon'] + " in the " + message['answer']['room'];
        		  alert (ans);
        	  }
        	  if (message['event'] == 'notification'){
        		  if (message['notify_players'].indexOf(user) > -1){
            		  alert (message['notify_message']);
        		  }
        	  }
        	  if (message['event'] == 'suggestion'){
        		  var sug = message['user'] + " suggested it was " + message['suggestion_made']['character'] + " with the " + message['suggestion_made']['weapon'] + " in the " + message['suggestion_made']['room'];
        		  alert (sug);
        	  }
        	  if (message['event'] == 'disprove_reply'){
        		  alert (message['next_turn']);
        	  }
          }
        } catch(exception) {

        }
      }


      function send() {
        var text = $("#message").val();
        if (text == '') {

        return;
        }

        try {
          socket.send(text);

        } catch(exception) {

        }

      }

      $(function() {
        connect();
      });


      $("#disconnect").click(function() {
        socket.close()
      });