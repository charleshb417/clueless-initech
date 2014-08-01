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