var user;

$(document).ready(function(){

	// User first logs on
	$("#usrSubmit").on('click', function(){
		$("#logonScreen").addClass("hidden");
		user = $("#userLogin").val();
		
		msg = {'event':'add_user', 'username':user};
        socket.send(JSON.stringify(msg));
		
		$("#userList").removeClass("hidden");
	});
	
	// Somebody hits "Play Game" button
	$("#startGameBtn").on('click', function(){
		msg = {'event':'deal'};
        socket.send(JSON.stringify(msg));
	});
	
	$("#removeUsr").click(function(){
		msg = {'event':'remove_user', 'username':user};
        socket.send(JSON.stringify(msg));
	});
	
	$("#movePlayer").click(function(){
		msg = {'event':'move', 'user':user, 'newRoom':'Kitchen'};
        socket.send(JSON.stringify(msg));
	});
	
	$("#changeTurn").on('click', function(){
		msg = {'event':'turnSwitch'};
        socket.send(JSON.stringify(msg));
	});
	
	$("#accuse").on('click', function(){
		msg = {'event':'accusation', 'character':'Miss Scarlett', 'weapon':'Knife', 'room':'Study'};
        socket.send(JSON.stringify(msg));
	});
	
	$("#gameBoard").on('click', '#notifyBtn', function(){
		msg = {'event':'notify', 'playerList':[user], 'note':'This is a test note.'};
        socket.send(JSON.stringify(msg));
	});
	
});


function fillWaitingRoom(users){
	var html = "";
	for (var key in users) {
		  if (users.hasOwnProperty(key)) {
		    html += key + "<br/>";
		  }
		}
	$("#waiting_room").html(html);
}

function startGame(users){
	var html = "";
	var cards = users[user]['cards'];
	var char = users[user]['character'];
	var room = users[user]['currentRoom'];

	html = "Your cards are: " + JSON.stringify(cards) + "<br/>";
	html += "You are playing as: " + char + "<br/>";
	html += "You are currently in the " + room + "<br/>";
	
	$("#userList").addClass("hidden");
	$("#gameBoard").removeClass("hidden");

	$("#dynamicBoard").html(html);
}