class MySQL {

	handle = null;

	constructor() {
		this.handle = mysql.connect("176.31.253.42", "ecrpmysql", "ecrpmysql1337", "ecrp_game");
	}

	function Query(query) {
		mysql.query(handle, query);
	}

	function FetchRow() {
		mysql.fetch_row(handle);
	}

	function FreeResult() {
		mysql.free_result(handle);
	}

	function Close() {
		mysql.close(handle);
	}

	function MasterAccountExists(gameId) {		
		mysql.query(handle, "SELECT game_id FROM masteraccount WHERE game_id = " + gameId);
		mysql.store_result(handle);

		local numRows = mysql.num_rows(handle);

		mysql.free_result(handle);

		return numRows > 0;
	}

	function RegisterMasterAccount(gameId) {
		mysql.query(handle, "INSERT INTO masteraccount (game_id) VALUES (" + gameId + ")");
	}

	function GetMasterAccount(gameId) {
		mysql.query(handle, "SELECT * FROM masteraccount WHERE game_id = " + gameId);
		mysql.store_result(handle);

		local dataTable = {};

		while(mysql.fetch_row(handle)) {
			dataTable.id <- mysql.fetch_field_row(handle, 0).tointeger();
			dataTable.game_id <- mysql.fetch_field_row(handle, 1);
			dataTable.admin_level <- mysql.fetch_field_row(handle, 2).tointeger();
		}

		mysql.free_result(handle);

		return dataTable;
	}

	function AccountExists(masterAccountId) {
		mysql.query(handle, "SELECT masteraccount_id FROM account WHERE masteraccount_id = " + masterAccountId);
		mysql.store_result(handle);

		local numRows = mysql.num_rows(handle);

		mysql.free_result(handle);

		return numRows > 0;
	}

	function GetAccounts(masterAccountId) {
		mysql.query(handle, "SELECT id, name FROM account WHERE masteraccount_id = " + masterAccountId);
		mysql.store_result(handle);

		local dataTable = {};

		while(mysql.fetch_row(handle)) {
			local id = mysql.fetch_field_row(handle, 0);
			
			dataTable[id] <- {};
			dataTable[id].name <- mysql.fetch_field_row(handle, 1);
		}

		mysql.free_result(handle);

		return dataTable;
	}

	function GetCharacter(id) {
		mysql.query(handle, "SELECT id, name, experience, inventory_id, pos_x, pos_y, pos_z, heading, health, money, current_business_id FROM account WHERE id = " + id);
		mysql.store_result(handle);

		local dataTable = {};

		while(mysql.fetch_row(handle)) {
			dataTable.id <- mysql.fetch_field_row(handle, 0);
			dataTable.name <- mysql.fetch_field_row(handle, 1);
			dataTable.experience <- mysql.fetch_field_row(handle, 2);
			dataTable.inventory_id <- mysql.fetch_field_row(handle, 3);
			dataTable.pos_x <- mysql.fetch_field_row(handle, 4);
			dataTable.pos_y <- mysql.fetch_field_row(handle, 5);
			dataTable.pos_z <- mysql.fetch_field_row(handle, 6);
			dataTable.heading <- mysql.fetch_field_row(handle, 7);
			dataTable.health <- mysql.fetch_field_row(handle, 8);
			dataTable.money <- mysql.fetch_field_row(handle, 9);

			// here is where i noticed its all string
			dataTable.current_business_id <- mysql.fetch_field_row(handle, 10).tointeger();
		}

		mysql.free_result(handle);

		return dataTable;
	}

	function CreateAccount(cPlayer, name, inventoryId) {
		mysql.query(handle, "INSERT INTO account (masteraccount_id, name, inventory_id) VALUES (" + cPlayer.GetMasterAccountID() + ", '" + name + "', " + inventoryId + ")");
	}

	function CreateInventory(name, weight) {
		mysql.query(handle, "INSERT INTO inventory (name, max_weight) VALUES ('" + name + "', " + weight + ")");

		local inventoryId = -1;
		local name = "";
		local maxWeight = -1;

		mysql.query(handle, "SELECT id, name, max_weight FROM inventory ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			inventoryId = mysql.fetch_field_row(handle, 0);
			name = mysql.fetch_field_row(handle, 1);
			maxWeight = mysql.fetch_field_row(handle, 2);
		}

		mysql.free_result(handle);

		return [inventoryId, name, maxWeight];
	}

	function LoadInventories() {
		mysql.query(handle, "SELECT id, name, max_weight FROM inventory");
		mysql.store_result(handle);

		local dataTable = {};
		local counter = 0;

		while(mysql.fetch_row(handle)) {
			dataTable.id <- mysql.fetch_field_row(handle, 0);
			dataTable.name <- mysql.fetch_field_row(handle, 1);
			dataTable.max_weight <- mysql.fetch_field_row(handle, 2);

			local cInventory = CInventory(dataTable.id, dataTable.name, dataTable.max_weight);
			CGame.GetEntityManager().GetInventoryManager().AddInventory(dataTable.id, cInventory);

			counter++;
		}

		mysql.free_result(handle);

		print(counter + " inventories loaded.");

		counter = 0;

		foreach(cInventory in CGame.GetEntityManager().GetInventoryManager().GetInventories()) {
			mysql.query(handle, "SELECT inventory.id, inventory_item.item_id, item.item_template_id, item.quantity FROM inventory LEFT JOIN inventory_item ON inventory.id = inventory_item.inventory_id LEFT JOIN item ON inventory_item.item_id = item.id WHERE inventory.id = " + cInventory.GetID());
			mysql.store_result(handle);

			if(mysql.num_rows(handle) > 0) {
				while(mysql.fetch_row(handle)) {
					if((mysql.fetch_field_row(handle, 1) && mysql.fetch_field_row(handle, 2) && mysql.fetch_field_row(handle, 3)) != 0) {
						local cItem = CItem(mysql.fetch_field_row(handle, 2).tointeger(), cInventory.GetID(), mysql.fetch_field_row(handle, 3).tointeger());
						cItem.SetID(mysql.fetch_field_row(handle, 1).tointeger());

						cInventory.AddItem(cItem);
					}
					//else {
						//print("WARNING:: Found inventory with no item, inventory id: " + cInventory.GetID());
					//}
					counter++;
				}
			}
			else {
				print("FATAL ERROR:: No inventory item found!");
			}
		}

		print(counter + " inventory items loaded.");
	}

	function InsertItemTemplate(name, reference, qualityId, description, weight, abilityTable, active) {
		mysql.query(handle, "INSERT INTO item_template (name, reference, quality_id, description, weight) VALUES ('" + name + "', '" + reference + "', " + qualityId + ", '" + description + "', " + weight + ")");
	
		local itemTemplateId = -1;

		mysql.query(handle, "SELECT id FROM item_template ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			itemTemplateId = mysql.fetch_field_row(handle, 0);
		}

		mysql.free_result(handle);

		foreach(abilityKey, abilityValue in abilityTable) {
			mysql.query(handle, "INSERT INTO item_template_ability (item_template_id, `key`, `value`, `active`) VALUES (" + itemTemplateId + ", '" + abilityKey + "', " + abilityValue + ", " + active +")");
		}

		mysql.query(handle, "SELECT name, color FROM item_template_quality WHERE id = " + qualityId);
		mysql.store_result(handle);

		local qualityName = "undefined";
		local qualityColor = "undefined";

		while(mysql.fetch_row(handle)) {
			qualityName = mysql.fetch_field_row(handle, 0);
			qualityColor = mysql.fetch_field_row(handle, 1);
		}

		mysql.free_result(handle);

		CGame.GetEntityManager().GetItemTemplateManager().AddItemTemplate(CItemTemplate(itemTemplateId.tointeger(), name, reference, qualityId.tointeger(), description, weight.tointeger(), qualityName, qualityColor));
		local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(reference);

		foreach(abilityKey, abilityValue in abilityTable) {
			itemTemplate.AddAbility(CItemTemplateAbility(abilityKey, abilityValue.tointeger(), active.tointeger()));
		}
	}

	function LoadItemTemplates() {
		mysql.query(handle, "SELECT item_template.id, item_template.name, item_template.reference, item_template.quality_id, item_template.description, item_template.weight, item_template_quality.name AS quality_name, item_template_quality.color FROM item_template LEFT JOIN item_template_quality ON item_template.quality_id = item_template_quality.id");
		mysql.store_result(handle);

		local dataTable = {};
		local counter = 0;

		while(mysql.fetch_row(handle)) {
			dataTable.id <- mysql.fetch_field_row(handle, 0);
			dataTable.name <- mysql.fetch_field_row(handle, 1);
			dataTable.reference <- mysql.fetch_field_row(handle, 2);
			dataTable.quality_id <- mysql.fetch_field_row(handle, 3);
			dataTable.description <- mysql.fetch_field_row(handle, 4);
			dataTable.weight <- mysql.fetch_field_row(handle, 5);
			dataTable.quality_name <- mysql.fetch_field_row(handle, 6);
			dataTable.color <- mysql.fetch_field_row(handle, 7);

			CGame.GetEntityManager().GetItemTemplateManager().AddItemTemplate(CItemTemplate(dataTable.id.tointeger(), dataTable.name, dataTable.reference, dataTable.quality_id.tointeger(), dataTable.description, dataTable.weight.tointeger(), dataTable.quality_name, dataTable.color));
			
			counter++;
		}

		mysql.free_result(handle);
		print(counter + " item templates loaded.");

		counter = 0;

		foreach(itemTemplate in CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplates()) {
			mysql.query(handle, "SELECT * FROM item_template_ability WHERE item_template_id = " + itemTemplate.GetID());
			mysql.store_result(handle);

			if(mysql.num_rows(handle) > 0) {
				while(mysql.fetch_row(handle)) {
					itemTemplate.AddAbility(CItemTemplateAbility(mysql.fetch_field_row(handle, 1), mysql.fetch_field_row(handle, 2).tointeger(), mysql.fetch_field_row(handle, 3).tointeger()));
					counter++;
				}
			}
			else {
				print("WARNING:: No ability found for: " + itemTemplate.GetName());
			}

			mysql.free_result(handle);
		}

		print(counter + " item abilities loaded.");
	}

	function SavePlayer(cPlayer) {
		local query = 	"UPDATE account SET " +
						"experience = " + cPlayer.GetExperience() + 
						", pos_x = '" + cPlayer.GetPlayer().GetPosition().x + 
						"', pos_y = '" + cPlayer.GetPlayer().GetPosition().y + 
						"', pos_z = '" + cPlayer.GetPlayer().GetPosition().z + 
						"', heading = '" + cPlayer.GetPlayer().GetCurrentHeading() + 
						"', health = '" + cPlayer.GetPlayer().GetHealth() + "'";


		if(cPlayer.GetCurrentBusiness() != null) {
			query += ", current_business_id = " + cPlayer.GetCurrentBusiness().GetID();
		}

		query += " WHERE id = " + cPlayer.GetID();

		mysql.query(handle, query);
	}

	function InsertInventoryItem(inventoryId, itemTemplateId, quantity) {
		mysql.query(handle, "INSERT INTO item (item_template_id, quantity) VALUES ('" + itemTemplateId + "', " + quantity + ")");

		local itemId = -1;

		mysql.query(handle, "SELECT id FROM item ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			itemId = mysql.fetch_field_row(handle, 0);
		}

		mysql.free_result(handle);

		mysql.query(handle, "INSERT INTO inventory_item (inventory_id, item_id) VALUES ('" + inventoryId + "', " + itemId + ")");

		return itemId;
	}

	function UpdateInventoryItem(id, cItem) {
		mysql.query(handle, "SELECT inventory_item.inventory_id, inventory_item.item_id, item.item_template_id, item.quantity FROM inventory_item LEFT JOIN item ON inventory_item.item_id = item.id WHERE inventory_item.inventory_id = " + id + " AND item.item_template_id = " + cItem.GetItemTemplateID());
		mysql.store_result(handle);

		local itemId = -1;
		local itemTemplateId = -1;

		if(mysql.num_rows(handle) > 0) {
			while(mysql.fetch_row(handle)) {
				itemId = mysql.fetch_field_row(handle, 1);
				itemTemplateId = mysql.fetch_field_row(handle, 2);
			}
		}
		else {
			print("FATAL ERROR:: No inventory item update found!");
		}

		mysql.query(handle, "UPDATE item SET quantity = " + cItem.GetQuantity() + " WHERE id = " + itemId + " AND item_template_id = " + itemTemplateId);
	}

	function DeleteInventoryItem(itemId) {
		mysql.query(handle, "DELETE FROM inventory_item WHERE item_id = " + itemId);
		mysql.query(handle, "DELETE FROM item WHERE id = " + itemId);
	}

	function LoadBusinesses() {
		local counter = 0;

		mysql.query(handle, "SELECT id, inventory_id, name, pos_x, pos_y, pos_z, is_locked, scriptset FROM business");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			local inventory = CGame.GetEntityManager().GetInventoryManager().GetInventory(mysql.fetch_field_row(handle, 1));

			CGame.GetEntityManager().GetBusinessManager().AddBusiness(CBusiness(mysql.fetch_field_row(handle, 0).tointeger(), inventory, mysql.fetch_field_row(handle, 2), mysql.fetch_field_row(handle, 3).tofloat(), mysql.fetch_field_row(handle, 4).tofloat(), mysql.fetch_field_row(handle, 5).tofloat(), mysql.fetch_field_row(handle, 6).tointeger(), mysql.fetch_field_row(handle, 7)));
			counter++;
		}

		mysql.free_result(handle);

		foreach(business in CGame.GetEntityManager().GetBusinessManager().GetBusinesses()) {
			mysql.query(handle, "SELECT account_id, level FROM business_member WHERE business_id = " + business.GetID());
			mysql.store_result(handle);

			while(mysql.fetch_row(handle)) {
				business.AddMember(mysql.fetch_field_row(handle, 0).tointeger(), mysql.fetch_field_row(handle, 1).tointeger());
			}

			mysql.free_result(handle);
		}

		print(counter + " businesses loaded.");
	}

	function InsertBusiness(cPlayerId, inventoryId, name, posX, posY, posZ, isLocked, scriptSet) {
		mysql.query(handle, "INSERT INTO business (inventory_id, name, pos_x, pos_y, pos_z, is_locked, scriptset) VALUES (" + inventoryId + ", '" + name + "', '" + posX +"', '" + posY +"', '" + posZ + "', " + isLocked + ", '" + scriptSet + "')");

		local businessId = -1;

		mysql.query(handle, "SELECT id FROM business ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			businessId = mysql.fetch_field_row(handle, 0);
		}

		mysql.free_result(handle);

		mysql.query(handle, "INSERT INTO business_member (business_id, account_id, level) VALUES (" + businessId + ", " + cPlayerId + ", 1)");

		return businessId;
	}

	function InsertBusinessMember(businessId, cPlayerId, level) {
		mysql.query(handle, "INSERT INTO business_member (business_id, account_id, level) VALUES (" + businessId + ", " + cPlayerId + ", " + level + ")");
	}

	function DeleteBusinessMember(businessId, cPlayerId) {
		mysql.query(handle, "DELETE FROM business_member WHERE business_id = " + businessId + " AND account_id = " + cPlayerId);
	}

	function LoadHouses() {
		local counter = 0;

		mysql.query(handle, "SELECT id, inventory_id, owner_account_id, name, pos_x, pos_y, pos_z, is_locked FROM house");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			local inventory = CGame.GetEntityManager().GetInventoryManager().GetInventory(mysql.fetch_field_row(handle, 1));

			CGame.GetEntityManager().GetHouseManager().AddHouse(CHouse(mysql.fetch_field_row(handle, 0).tointeger(), inventory, mysql.fetch_field_row(handle, 2).tointeger(), mysql.fetch_field_row(handle, 3), mysql.fetch_field_row(handle, 4).tofloat(), mysql.fetch_field_row(handle, 5).tofloat(), mysql.fetch_field_row(handle, 6).tofloat(), mysql.fetch_field_row(handle, 7).tointeger()));		
			counter++;
		}

		mysql.free_result(handle);

		print(counter + " houses loaded.");
	}

	function InsertHouse(cPlayerId, inventoryId, name, posX, posY, posZ, isLocked) {
		mysql.query(handle, "INSERT INTO house (owner_account_id, inventory_id, name, pos_x, pos_y, pos_z, is_locked) VALUES (" + cPlayerId + ", " + inventoryId + ", '" + name + "', '" + posX +"', '" + posY +"', '" + posZ + "', " + isLocked + ")");

		local houseId = -1;

		mysql.query(handle, "SELECT id FROM house ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			houseId = mysql.fetch_field_row(handle, 0).tointeger();
		}

		mysql.free_result(handle);

		return houseId;
	}

	function LoadVehicles() {
		local counter = 0;

		mysql.query(handle, "SELECT id, owner_account_id, inventory_id, model_id, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, is_locked FROM vehicle");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			local inventory = CGame.GetEntityManager().GetInventoryManager().GetInventory(mysql.fetch_field_row(handle, 2));

			local vehicleRef = Vehicle.Create(mysql.fetch_field_row(handle, 3).tointeger(), mysql.fetch_field_row(handle, 4).tofloat(), mysql.fetch_field_row(handle, 5).tofloat(), mysql.fetch_field_row(handle, 6).tofloat(), mysql.fetch_field_row(handle, 7).tofloat(), mysql.fetch_field_row(handle, 8).tofloat(), mysql.fetch_field_row(handle, 9).tofloat());

			CGame.GetEntityManager().GetVehicleManager().AddVehicle(CVehicle(mysql.fetch_field_row(handle, 0).tointeger(), inventory, vehicleRef, mysql.fetch_field_row(handle, 10).tointeger()));

			counter++;
		}

		mysql.free_result(handle);

		print(counter + " vehicles loaded.");
	}

	function InsertVehicle(cPlayerId, inventoryId, modelId, posX, posY, posZ, rotX, rotY, rotZ, isLocked) {
		mysql.query(handle, "INSERT INTO vehicle (owner_account_id, inventory_id, model_id, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, is_locked) VALUES (" + cPlayerId + ", " + inventoryId + ", " + modelId + ", '" + posX +"', '" + posY +"', '" + posZ + "', '" + rotX + "', '" + rotY + "', '" + rotZ + "', " + isLocked + ")");

		local carId = -1;

		mysql.query(handle, "SELECT id FROM vehicle ORDER BY id DESC LIMIT 1");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			carId = mysql.fetch_field_row(handle, 0);
		}

		mysql.free_result(handle);

		return carId;
	}

	function SaveVehicle(cVehicle) {
		// we use the player's heading because as of this time the vehicle doesnt have GetCurrentHeading...
		local query = 	"UPDATE vehicle SET " +
						"pos_x = '" + cVehicle.GetVehicle().GetPosition().x + 
						"', pos_y = '" + cVehicle.GetVehicle().GetPosition().y + 
						"', pos_z = '" + cVehicle.GetVehicle().GetPosition().z + 
						"', rot_x = '" + cVehicle.GetVehicle().GetRotation().x + 
						"', rot_y = '" + cVehicle.GetVehicle().GetRotation().y + 
						"', rot_z = '" + cVehicle.GetVehicle().GetRotation().z + 
						"', is_locked = " + cVehicle.IsLocked() + " WHERE id = " + cVehicle.GetID();

		mysql.query(handle, query);
	}

	function AddSaleItem(businessId, itemId, price, description) {
		mysql.query(handle, "INSERT INTO business_item_sale (business_id, item_id, price, description) VALUES (" + businessId + ", " + itemId + ", " + price + ", '" + description + "')");
	}

	function LoadSaleItems() {
		local counter = 0;

		mysql.query(handle, "SELECT business_id, item_id, price, description FROM business_item_sale");
		mysql.store_result(handle);

		while(mysql.fetch_row(handle)) {
			local business = CGame.GetEntityManager().GetBusinessManager().GetBusiness(mysql.fetch_field_row(handle, 0).tointeger());
			local item = business.GetInventory().GetItemByID(mysql.fetch_field_row(handle, 1).tointeger());

			if(item) {
				business.AddSaleItem(item, mysql.fetch_field_row(handle, 2).tointeger(), mysql.fetch_field_row(handle, 3));
			}
			else {
				print("FATAL ERROR:: Could not find item!");
			}

			counter++;
		}

		mysql.free_result(handle);

		print(counter + " sale items loaded.");
	}

	function RemoveSaleItem(businessId, itemId) {
		mysql.query(handle, "DELETE FROM business_item_sale WHERE business_id = " + businessId + " AND item_id = " + itemId);
	}
	
}