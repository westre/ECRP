class CPlayerManager {
	
	players = null;

	constructor() {
		this.players = {};
	}

	function AddPlayer(player) {
		this.players[player] <- CPlayer(player);
	}

	function DeletePlayer(player) {
		delete this.players[player];
	}

	function GetPlayer(player) {
		return this.players[player];
	}

	function GetPlayerByID(cPlayerId) {
		foreach(player in this.players) {
			if(!player.IsLoggedIn()) continue;
			if(cPlayerId.tointeger() == player.GetID().tointeger())
				return player;
		}
		return null;
	}

	function GetPlayerByCharName(charName) {
		foreach(player in this.players) {
			if(!player.IsLoggedIn()) continue;
			if(charName == player.GetCharacterName()) {
				return player;
			}
		}
		return null;
	}

	function Exists(player) {
		return this.players.rawin(player);
	}

	function ExistsByID(cPlayerId) {
		foreach(player in this.players) {
			if(!player.IsLoggedIn()) continue;

			if(cPlayerId.tointeger() == player.GetID().tointeger())
				return true;
		}
		return false;
	}

	function GetPlayers() {
		return this.players;
	}

}