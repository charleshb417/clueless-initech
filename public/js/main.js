      var socket, host;
      host = "ws://localhost:3001";

      function connect() {
        try {
          socket = new WebSocket(host);


          socket.onopen = function() {
        	  
          }

          socket.onclose = function() {

          }

          socket.onmessage = function(msg) {

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