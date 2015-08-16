class CDeveloperScript {
	
	name = null;

	constructor(name) {
		this.name = name;

		Command.Add("createvehicle", this.CreateVehicle);
		Command.Add("createbusiness", this.CreateBusiness);
		Command.Add("createhouse", this.CreateHouse);
	}

	function CreateVehicle(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("developer")) return true;

		local vehicleRef = Vehicle.Create(600, player.GetPosition().x, player.GetPosition().y, player.GetPosition().z);

		// create inventory for vehicle
		local inventory = CGame.GetDatabase().CreateInventory("Car Inventory of " + cPlayer.GetCharacterName(), 33);	
		CGame.GetEntityManager().GetInventoryManager().AddInventory(inventory[0], CInventory(inventory[0], inventory[1], inventory[2]));

		local carId = CGame.GetDatabase().InsertVehicle(cPlayer.GetID(), inventory[0], 600, vehicleRef.GetPosition().x, vehicleRef.GetPosition().y, vehicleRef.GetPosition().z, vehicleRef.GetRotation().x, vehicleRef.GetRotation().y, vehicleRef.GetRotation().z, 1);

		local inventoryRef = CGame.GetEntityManager().GetInventoryManager().GetInventory(inventory[0]);
		CGame.GetEntityManager().GetVehicleManager().AddVehicle(CVehicle(carId, inventoryRef, vehicleRef, 1));

		// create a new item template so we can get the key of the created house
		local abilities = {};
		abilities["enter_vehicle"] <- carId;

		CGame.GetDatabase().InsertItemTemplate("Vehicle Key", "vehicle_key_" + carId, 2, "Just your generic vehicle key.", 1, abilities, 0);

		// create a new item from itemtemplate and give it to the player
		local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("vehicle_key_" + carId).GetID(), cPlayer.GetInventory().GetID(), 1);
		
		local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("vehicle_key_" + carId).GetID(), 1);

		newItem.SetID(itemId);
		cPlayer.GetInventory().AddItem(newItem);

		player.SendMessage("Here's your key!");
	}

	function CreateBusiness(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("developer")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			local inventory = CGame.GetDatabase().CreateInventory("Inventory of " + message, 100);	
			CGame.GetEntityManager().GetInventoryManager().AddInventory(inventory[0], CInventory(inventory[0], inventory[1], inventory[2]));

			local businessId = CGame.GetDatabase().InsertBusiness(cPlayer.GetID(), inventory[0], message, player.GetPosition().x, player.GetPosition().y, player.GetPosition().z, 1, "business");

			local inventoryRef = CGame.GetEntityManager().GetInventoryManager().GetInventory(inventory[0]);

			local business = CBusiness(businessId.tointeger(), inventoryRef, message, player.GetPosition().x, player.GetPosition().y, player.GetPosition().z, 1, "business");
			business.AddMember(cPlayer.GetID().tointeger(), 1);

			CGame.GetEntityManager().GetBusinessManager().AddBusiness(business);

			cPlayer.GetPlayer().SendMessage("Business created");
			if(!cPlayer.HasPermission("business")) cPlayer.GrantScriptSet("business");
		}
	}

	function CreateHouse(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("developer")) return true;

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			// create inventory for house
			local inventory = CGame.GetDatabase().CreateInventory("Inventory of " + message, 75);	
			CGame.GetEntityManager().GetInventoryManager().AddInventory(inventory[0], CInventory(inventory[0], inventory[1], inventory[2]));

			local houseId = CGame.GetDatabase().InsertHouse(cPlayer.GetID(), inventory[0], message, player.GetPosition().x, player.GetPosition().y, player.GetPosition().z, 1);

			local inventoryRef = CGame.GetEntityManager().GetInventoryManager().GetInventory(inventory[0]);
			CGame.GetEntityManager().GetHouseManager().AddHouse(CHouse(houseId, inventoryRef, cPlayer.GetID(), message, player.GetPosition().x, player.GetPosition().y, player.GetPosition().z, 1));

			// create a new item template so we can get the key of the created house
			local abilities = {};
			abilities["enter_house"] <- houseId;

			CGame.GetDatabase().InsertItemTemplate("House Key", "house_key_" + houseId, 2, "Just your generic house key.", 1, abilities, 0);

			// create a new item from itemtemplate and give it to the player
			local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("house_key_" + houseId).GetID(), cPlayer.GetInventory().GetID(), 1);
			
			local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("house_key_" + houseId).GetID(), 1);

			newItem.SetID(itemId);
			cPlayer.GetInventory().AddItem(newItem);

			player.SendMessage("Here's your key!");
		}
	}
}
