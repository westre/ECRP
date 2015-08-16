class CPlayer {
	
	player = null;
	masterAccountId = null;
	gameId = null;
	adminLevel = null;
	loggedIn = null;
	id = null;
	name = null;
	experience = null;
	inventory = null;
	scripts = null;
	characters = null;
	currentBusiness = null;
	itemOffer = null;
	hasItemOffer = null;
	sentItemOffer = null;
	sentItemOfferPlayer = null;

	constructor(player) {
		this.player = player;
		this.scripts = [];
		this.characters = [];

		this.loggedIn = false;
		this.hasItemOffer = false;
		this.itemOffer = {};
	}

	function GetPlayer() {
		return this.player;
	}

	function SetID(id) {
		this.id = id;
	}

	function GetID() {
		return this.id;
	}

	function SetCharacterName(name) {
		this.name = name;
	}

	function GetCharacterName() {
		return this.name;
	}

	function SetExperience(exp) {
		this.experience = exp;
	}

	function GetExperience() {
		return this.experience;
	}

	function SetInventory(inventory) {
		this.inventory = inventory;
	}

	function GetInventory() {
		return this.inventory;
	}

	function SetMasterAccountID(id) {
		this.masterAccountId = id;
	}

	function GetMasterAccountID() {
		return this.masterAccountId;
	}

	function SetGameID(id) {
		this.gameId = id;
	}

	function GetGameID() {
		return this.gameId;
	}

	function SetAdminLevel(level) {
		this.adminLevel = level;
	}

	function GetAdminLevel() {
		return this.adminLevel;
	}

	function SetCurrentBusiness(business) {
		this.currentBusiness = business;
	}

	function GetCurrentBusiness() {
		return this.currentBusiness;
	}

	function GrantScriptSet(name) {
		this.scripts.push(name);
		this.player.SendMessage("#ccccccGranted ScriptSet: " + name + " (/" + name + " help)");
	}

	function RemoveScriptSet(name) {
		for(local index = 0; index < scripts.len(); index++) {
			if(name == scripts[index]) {
				this.scripts.remove(index);
				this.player.SendMessage("#ccccccRemoved ScriptSet: " + name);
				break;
			}
		}
	}

	function HasPermission(name) {
		foreach(script in scripts) {
			if(script == name)
				return true;
		}
		return false;
	}

	function GetScriptSets() {
		return this.scripts;
	}

	function AddCharacter(name) {
		this.characters.push(name);
	}

	function GetCharacters() {
		return this.characters;
	}

	function SetLoggedIn(toggle) {
		this.loggedIn = toggle;
	}

	function IsLoggedIn() {
		return this.loggedIn;
	}

	function GetItemOffer() {
		return this.itemOffer;
	}

	function HasItemOfferPending() {
		return this.hasItemOffer;
	}

	function SetItemOfferPending(pending) {
		this.hasItemOffer = pending;
	}

	function HasSentItemOffer() {
		return this.sentItemOffer;
	}

	function SetSentItemOffer(toggle) {
		this.sentItemOffer = toggle;
	}

	function SetSentItemOfferPlayer(cPlayer) {
		this.sentItemOfferPlayer = cPlayer;
	}

	function GetSentItemOfferPlayer() {
		return this.sentItemOfferPlayer;
	}

	function SetItemOffer(originCPlayer, item) {
		this.itemOffer.origin <- originCPlayer;
		this.itemOffer.item <- item;
	}

	function RefreshAccounts() {
		if(CGame.GetDatabase().AccountExists(GetMasterAccountID())) {
			player.SendMessage("");
			player.SendMessage("We have found characters linked to your account. Please select a character.");
			player.SendMessage("#00ff00-----------------------------------------------");
			foreach(accountId, account in CGame.GetDatabase().GetAccounts(GetMasterAccountID())) {
				player.SendMessage("[ID: " + accountId + "] " + account.name + " #cccccc(type /spawn " + accountId + " to spawn)");

				AddCharacter(accountId);
			}
			player.SendMessage("#00ff00-----------------------------------------------");
		}
		else {
			player.SendMessage("No character found, please create one with #00ff00/create [name]#ffffff.");
		}
	}

	function GetDistanceBetween(vector) {
		local a = this.player.GetPosition().x - vector.x;
		local b = this.player.GetPosition().y - vector.y;
		local c = this.player.GetPosition().z - vector.z;
		local _x = abs(a);
		local _y = abs(b);
		local _z = abs(c);
		return sqrt((_x * _x + _y * _y + _z * _z))
	}

	function GetDistanceBetweenXYZ(x, y, z) {
		local a = this.player.GetPosition().x - x;
		local b = this.player.GetPosition().y - y;
		local c = this.player.GetPosition().z - z;
		local _x = abs(a);
		local _y = abs(b);
		local _z = abs(c);
		return sqrt((_x * _x + _y * _y + _z * _z))
	}

}