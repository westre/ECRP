class CVehicleScript {
	
	name = null;

	constructor(name) {
		this.name = name;

		Command.Add("vehicle", this.Vehicle);
	}

	function Vehicle(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("vehicle")) return true;

		if(vargv.len() == 1) {
			local command = vargv[0];

			if(command == "help") {
				player.SendMessage("/vehicle inventory");
			}
			else if(command == "inventory") {
				local cVehicle = CGame.GetEntityManager().GetVehicleManager().GetVehicle(player.GetVehicle());

				player.SendMessage("#00ffff------[" + cVehicle.GetInventory().GetName() + "(" + cVehicle.GetInventory().GetCurrentWeight() + "/" + cVehicle.GetInventory().GetMaxWeight() + ")]------");
				foreach(item in cVehicle.GetInventory().GetItems()) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());			

					local isPassiveItem = false;
					if(itemTemplate.GetAbilities().len() > 0) {
						foreach(itemAbility in itemTemplate.GetAbilities()) {
							if(itemAbility.IsActive().tointeger() == 0)
								isPassiveItem = true;
						}
					}

					if(!isPassiveItem)
						player.SendMessage("#" + itemTemplate.GetColor() + itemTemplate.GetName() + " #ffffffQty: " + item.GetQuantity() + " W: " + itemTemplate.GetWeight() + " #cccccc(" + itemTemplate.GetReference() + ")");
					else
						player.SendMessage("#" + itemTemplate.GetColor() + itemTemplate.GetName() + " #ffffffQty: " + item.GetQuantity() + " W: " + itemTemplate.GetWeight());

					if(itemTemplate.GetAbilities().len() > 0) {
						foreach(itemAbility in itemTemplate.GetAbilities()) {
							if(itemAbility.IsActive().tointeger() == 1)
								player.SendMessage("#00ff00- " + itemAbility.GetKey() + ":" + itemAbility.GetValue() + " #ccccccACTIVE");
							else if(itemAbility.IsActive().tointeger() == 0)
								player.SendMessage("#ff0000- " + itemAbility.GetKey() + ":" + itemAbility.GetValue() + " #ccccccPASSIVE");
						}
					}
					else {
						player.SendMessage("#0000ff- undefined, please report to dev");
					}
					
				}
				player.SendMessage("#00ffff------------");
			}
		}
		else if(vargv.len() == 2) {
			local command = vargv[0];
			
			if(command == "additem") {
				local cVehicle = CGame.GetEntityManager().GetVehicleManager().GetVehicle(player.GetVehicle());

				local item = cPlayer.GetInventory().GetItem(vargv[1]);

				if(item) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
					
					if(item.GetQuantity() > 0) {
						local vehicleItem = cVehicle.GetInventory().GetItem(itemTemplate.GetReference());
						if(vehicleItem) {
							vehicleItem.SetQuantity(vehicleItem.GetQuantity() + 1);
							player.SendMessage("Item found, appending");

							//hmmm
							CGame.GetDatabase().UpdateInventoryItem(cVehicle.GetInventory().GetID(), vehicleItem);
						}
						else {
							local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), cVehicle.GetInventory().GetID(), 1);
							
							local itemId = CGame.GetDatabase().InsertInventoryItem(cVehicle.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), 1);

							newItem.SetID(itemId);
							cVehicle.GetInventory().AddItem(newItem);

							player.SendMessage("Item not found, created new item");
						}

						item.SetQuantity(item.GetQuantity() - 1);
						// if quantity == 0, remove item from inventory
						item.CheckValidity(cPlayer.GetInventory().GetID());
					}
					else {
						player.SendMessage("Error, CBusinessScript::cVehicle.AddItem");
					}
				}
				else {
					player.SendMessage("Item not found.");
				}
			}
			else if(command == "takeitem") {
				local cVehicle = CGame.GetEntityManager().GetVehicleManager().GetVehicle(player.GetVehicle());

				local item = cVehicle.GetInventory().GetItem(vargv[1]);

				if(item) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
					
					if(item.GetQuantity() > 0) {
						local playerItem = cPlayer.GetInventory().GetItem(itemTemplate.GetReference());
						if(playerItem) {
							playerItem.SetQuantity(playerItem.GetQuantity() + 1);
							player.SendMessage("Item found, appending");

							//hmmm
							CGame.GetDatabase().UpdateInventoryItem(cPlayer.GetInventory().GetID(), playerItem);
						}
						else {
							local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), cPlayer.GetInventory().GetID(), 1);
							
							local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), 1);

							newItem.SetID(itemId);
							cPlayer.GetInventory().AddItem(newItem);

							player.SendMessage("Item not found, created new item");
						}

						item.SetQuantity(item.GetQuantity() - 1);
						// if quantity == 0, remove item from inventory
						item.CheckValidity(cVehicle.GetInventory().GetID());
						cVehicle.CheckSaleItemValidity();
					}
					else {
						player.SendMessage("Error, CBusinessScript::cVehicle.AddItem");
					}
				}
				else {
					player.SendMessage("Item not found.");
				}
			}
		}
	}
}
