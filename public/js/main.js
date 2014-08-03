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
        	  if (message['user_update']){
        		  fillWaitingRoom(message['user_update']);
        	  }
        	  if (message['start_game']){
        		  startGame(message['start_game']);
        	  }
        	  if (message['move_reply']){
        		  alert (message['move_reply']);
        	  }
        	  if (message['newTurn']){
        		  alert (message['newTurn']);
        	  }
        	  if (message['accusation_result'] == true || message['accusation_result'] == false){
        		  alert (message['accusation_result']);
        		  var ans = message['answer']['character'] + " with the " + message['answer']['weapon'] + " in the " + message['answer']['room'];
        		  alert (ans);
        	  }
        	  if (message['notify_message']){
        		  if (message['notify_players'].indexOf(user) > -1){
            		  alert (message['notify_message']);
        		  }
        	  }
        	  if (message['suggestion_made']){
        		  var sug = message['user'] + " suggested it was " + message['suggestion_made']['character'] + " with the " + message['suggestion_made']['weapon'] + " in the " + message['suggestion_made']['room'];
        		  alert (sug);
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