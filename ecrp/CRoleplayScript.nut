class CRoleplayScript {
	
	name = null;

	constructor(name) {
		this.name = name;

		Command.Add("ooc", this.OOC);
		Command.Add("o", this.OOC);
		Command.Add("me", this.Me);
		Command.Add("do", this.Do);
		Command.Add("b", this.LocalOOC);
		Command.Add("s", this.Shout);
		Command.Add("shout", this.Shout);
		Command.Add("l", this.Low);
		Command.Add("low", this.Low);
		Command.Add("roleplay", this.Roleplay)
	}

	function Roleplay(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() == 1) {
			local command = vargv[0];

			if(command == "help") {
				player.SendMessage("/o(oc) #ccccccPublic OOC chat");
				player.SendMessage("/me #ccccccDisplays action your character is performing");
				player.SendMessage("/do #ccccccIC emote");
				player.SendMessage("/b #ccccccLocal OOC chat");
				player.SendMessage("/s(hout) #ccccccShout");
				player.SendMessage("/l(ow) #ccccccShort distance IC chat");
			}
		}
	}

	function OOC(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			if(cPlayer.GetAdminLevel() > 0)
				Player.BroadcastMessage("#FF5500(( [OOC] Staff " + player.GetName() + ": " + message + " ))");
			else
				Player.BroadcastMessage("#FF5500(( [OOC] " + player.GetName() + ": " + message + " ))");
		}	
	}

	function Me(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 30) {
					loopPlayer.SendMessage("#C2A2DA* " + cPlayer.GetCharacterName() + " " + message + " (dist: " + cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) + ")");
				}
			}
		}		
	}

	function Do(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 30) {
					loopPlayer.SendMessage("#C2A2DA* " + message + " (( " + cPlayer.GetCharacterName() + " ))");
				}
			}	
		}		
	}

	function LocalOOC(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 30) {
					if(cPlayer.GetAdminLevel() > 0)
						loopPlayer.SendMessage("#00F5FF(( Staff " + player.GetName() + ": " + message + " ))");
					else
						loopPlayer.SendMessage("#00F5FF(( " + player.GetName() + ": " + message + " ))");
				}
			}
		}			
	}

	function Shout(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 60) {
					loopPlayer.SendMessage(cPlayer.GetCharacterName() + " shouts: " + message);
				}
			}
		}	
	}

	function Low(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("roleplay")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 5) {
					loopPlayer.SendMessage(cPlayer.GetCharacterName() + " whispers: " + message);
				}
			}
		}		
	}
}
