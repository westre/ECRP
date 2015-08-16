class CEventManager {
	
	constructor() {
		Event.Add(Package, "start", this.PackageStart);
		Event.Add(Package, "stop", this.PackageStop);

		Event.Add(Player, "inGame", this.PlayerJoined);
		Event.Add(Player, "disconnect", this.PlayerDisconnected);
		Event.Add(Player, "death", this.PlayerDied);
		Event.Add(Player, "chat", this.PlayerChat);

		Event.Add(Player, "enterVehicle", this.EnterVehicle);
		Event.Add(Player, "exitVehicle", this.ExitVehicle);
	}

	function PackageStart(package, commandline) {
    	if(package == Package.Current()) {  		 		
      		CGame.GetDatabase().LoadInventories();
      		CGame.GetDatabase().LoadItemTemplates();
      		CGame.GetDatabase().LoadBusinesses(); 
      		CGame.GetDatabase().LoadHouses(); 
      		CGame.GetDatabase().LoadVehicles(); 
      		CGame.GetDatabase().LoadSaleItems();

      		print("ECRP Started");

      		foreach(player in Player.All()) {
      			Player.BroadcastMessage("#00ff00" + player.GetName() + " has joined the game");
	
				CGame.GetEntityManager().GetPlayerManager().AddPlayer(player);

				if(CGame.GetDatabase().MasterAccountExists(player.GetCloudAccountID())) {
					player.SendMessage("Account exists, welcome back!");
				}
				else {
					CGame.GetDatabase().RegisterMasterAccount(player.GetCloudAccountID());
					player.SendMessage("Your account has been registered. Welcome to Empire City Roleplay! ID: " + player.GetCloudAccountID());
				}

				local masterAccount = CGame.GetDatabase().GetMasterAccount(player.GetCloudAccountID());

				local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
				cPlayer.SetMasterAccountID(masterAccount.id);
				cPlayer.SetGameID(masterAccount.game_id);
				cPlayer.SetAdminLevel(masterAccount.admin_level);	
				cPlayer.SetLoggedIn(false);			
				cPlayer.GrantScriptSet("general");				

				if(cPlayer.GetAdminLevel() > 0) {
					cPlayer.GrantScriptSet("developer");
				}

				cPlayer.RefreshAccounts();

				// temporary
				player.SendMessage("#ff0000You will keep falling until you login/spawn in your character!");
				player.SetPosition(0.0, 0.0, 10000.0);
      		}
	   	}
	}

	function PackageStop(package) {
   		if(package == Package.Current()) {
   			foreach(vehicle in Vehicle.All()) {
   				vehicle.Destroy();
   			}

   			foreach(player in Player.All()) {
   				if(CGame.GetEntityManager().GetPlayerManager().Exists(player)) {
   					local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);

   					if(cPlayer.GetID() != null) {
   						CGame.GetDatabase().SavePlayer(cPlayer);
					}
   				}
   			}

	   		CGame.GetDatabase().Close();
      		print("ECRP Stopped");
	   	}
	}

	function PlayerJoined(player) {
		Player.BroadcastMessage("#00ff00" + player.GetName() + " has joined the game");

		CGame.GetEntityManager().GetPlayerManager().AddPlayer(player);

		if(CGame.GetDatabase().MasterAccountExists(player.GetCloudAccountID())) {
			player.SendMessage("Account exists, welcome back!");
		}
		else {
			CGame.GetDatabase().RegisterMasterAccount(player.GetCloudAccountID());
			player.SendMessage("Your account has been registered. Welcome to Empire City Roleplay! ID: " + player.GetCloudAccountID());
		}

		local masterAccount = CGame.GetDatabase().GetMasterAccount(player.GetCloudAccountID());

		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		cPlayer.SetMasterAccountID(masterAccount.id);
		cPlayer.SetGameID(masterAccount.game_id);
		cPlayer.SetAdminLevel(masterAccount.admin_level);	
		cPlayer.SetLoggedIn(false);			
		cPlayer.GrantScriptSet("general");				

		if(cPlayer.GetAdminLevel() > 0) {
			cPlayer.GrantScriptSet("developer");
		}

		cPlayer.RefreshAccounts();

		// temporary
		player.SendMessage("#ff0000You will keep falling until you login/spawn in your character!");
		player.SetPosition(0.0, 0.0, 10000.0);
	}

	function PlayerDisconnected(player, reason) {
		Player.BroadcastMessage("#00ff00" + player.GetName() + " has left the game" + ((reason == 1) ? " (Connection lost)" : ""));

		if(CGame.GetEntityManager().GetPlayerManager().Exists(player)) {
			local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);

			if(cPlayer.IsLoggedIn()) {
				CGame.GetDatabase().SavePlayer(cPlayer);	
				CGame.GetEntityManager().GetPlayerManager().DeletePlayer(player);
			}
		}
	}

	function PlayerDied(player) {
		Player.BroadcastMessage("#ff0000" + player.GetName() + " has died");
	}

	function PlayerChat(player, message) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		print("Talking: " + cPlayer.GetID() + "/" + cPlayer.GetCharacterName());

		if(cPlayer.IsLoggedIn()) {
			foreach(loopPlayer in Player.All()) {
				if(cPlayer.GetDistanceBetween(loopPlayer.GetPosition()) <= 30) {
					loopPlayer.SendMessage(cPlayer.GetCharacterName() + " says: " + message);
				}
			}
		}
		else {
			player.SendMessage("Please spawn first by using /spawn [id] or /create [name]!");
		}
		
		return false;
	}

	function EnterVehicle(player, vehicle, door, seat) {
		if(CGame.GetEntityManager().GetVehicleManager().Exists(vehicle)) {
			local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
			local cVehicle = CGame.GetEntityManager().GetVehicleManager().GetVehicle(vehicle);

			if(cVehicle.IsLocked() == 1) {
				player.SendMessage("#ff0000This vehicle is locked.");

				local item = cPlayer.GetInventory().GetItem("vehicle_key_" + cVehicle.GetID());
		
				if(item) {
					player.SendMessage("You do however have the right vehicle key.");
				}
				else {
					return false;
				}
			}

			cPlayer.GrantScriptSet("vehicle");
		}
		else {
			player.SendMessage("No CVehicle instance found! Developer pls!");
			return false;
		}
	}

	function ExitVehicle(player, vehicle) {
		if(CGame.GetEntityManager().GetVehicleManager().Exists(vehicle)) {
			local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
			local cVehicle = CGame.GetEntityManager().GetVehicleManager().GetVehicle(vehicle);

			CGame.GetDatabase().SaveVehicle(cVehicle);

			cPlayer.RemoveScriptSet("vehicle");
		}
		else {
			player.SendMessage("No CVehicle instance found! Developer pls!");
		}
	}
}