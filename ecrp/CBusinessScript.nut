class CBusinessScript {
	
	name = null;

	constructor(name) {
		this.name = name;

		Command.Add("business", this.Business);
		Command.Add("bc", this.BusinessChat);
	}

	function BusinessChat(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("business")) return true;
		if(cPlayer.GetCurrentBusiness() == null) {
			player.SendMessage("Please select a business first!");
			return true;
		}

		if(vargv.len() > 0) {
			local message = "";
			foreach(piece in vargv) {
				message += piece + " "; 
			}
			message = message.slice(0, message.len() - 1);

			foreach(cPlayerId, memberTable in cPlayer.GetCurrentBusiness().GetMembers()) {
				local isOnline = CGame.GetEntityManager().GetPlayerManager().ExistsByID(cPlayerId);
				if(isOnline) {
					local loopCPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayerByID(cPlayerId);
					loopCPlayer.GetPlayer().SendMessage("#00ffff(business) " + cPlayer.GetCharacterName() + ": " + message);
				}
				else {
					player.SendMessage("no");
				}
			}	
		}
	}

	function Business(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("business")) return true;

		if(vargv.len() == 0) {
			player.SendMessage("#00ffffYou're in the following businesses:");
			foreach(business in CGame.GetEntityManager().GetBusinessManager().GetBusinesses()) {
				print(business.GetName());
				foreach(cPlayerId, memberTable in business.GetMembers()) {
					if(cPlayerId.tointeger() == cPlayer.GetID().tointeger()) {
						player.SendMessage(business.GetName() + " (level " + memberTable.level + ") #ccccccID: " + business.GetID());
					}
				}
			}

			if(cPlayer.GetCurrentBusiness() == null)
				player.SendMessage("Please type in #00ffff/business set [id]#ffffff to set your current business.");
			else
				player.SendMessage("#00ffffCurrent active business: " + cPlayer.GetCurrentBusiness().GetName());
		}
		else if(vargv.len() == 1) {
			if(cPlayer.GetCurrentBusiness() == null) {
				player.SendMessage("Please select a business first!");
				return true;
			}

			local command = vargv[0];

			if(command == "help") {
				player.SendMessage("/business inventory #ccccccShows inventory of this business");
				player.SendMessage("/business members #ccccccLists online members by level");
				player.SendMessage("/business invite [charname] #ccccccFORCES someone to join your business");
				player.SendMessage("/business remove [charname] #ccccccRemoves a member");
				player.SendMessage("/business additem [itemref] #ccccccAdds item to inventory");
				player.SendMessage("/business takeitem [itemref] #ccccccTakes item from inventory");
				player.SendMessage("/business sellitem [itemref] [price] #ccccccPuts item for sale");
				player.SendMessage("/business unsellitem [itemref] #ccccccRemoves item for sale");
				player.SendMessage("/business tp #ccccccTEMP");
				player.SendMessage("/bc #ccccccBusiness chat");
			}
			else if(command == "inventory") {
				local business = cPlayer.GetCurrentBusiness();

				player.SendMessage("#00ffff------[" + business.GetInventory().GetName() + "(" + business.GetInventory().GetCurrentWeight() + "/" + business.GetInventory().GetMaxWeight() + ")]------");
				foreach(item in business.GetInventory().GetItems()) {
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
			else if(command == "members") {
				foreach(cPlayerId, memberTable in cPlayer.GetCurrentBusiness().GetMembers()) {
					local isOnline = CGame.GetEntityManager().GetPlayerManager().ExistsByID(cPlayerId);
					if(isOnline) {
						local loopCPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayerByID(cPlayerId);
						cPlayer.GetPlayer().SendMessage(loopCPlayer.GetCharacterName() + " #ccccccLevel " + memberTable.level);
					}
				}
			}
			else if(command == "tp") {
				local business = cPlayer.GetCurrentBusiness();

				cPlayer.GetPlayer().SetPosition(business.GetPosX(), business.GetPosY(), business.GetPosZ());
			}
		}
		else if(vargv.len() == 2) {
			local command = vargv[0];

			if(command == "set") {	
				local business = CGame.GetEntityManager().GetBusinessManager().Exists(vargv[1].tointeger());
				local level = -1;
				
				if(business) {
					business = CGame.GetEntityManager().GetBusinessManager().GetBusiness(vargv[1].tointeger());
					foreach(cPlayerId, memberTable in business.GetMembers()) {
						if(cPlayerId == cPlayer.GetID().tointeger()) {
							level = memberTable.level;
						}
					}

					if(level > 0) {
						if(command == "set") {
							cPlayer.SetCurrentBusiness(business);
							player.SendMessage("#00ffffSet your current business to: " + business.GetName());
						}
					}
					else {
						player.SendMessage("You are not part of this business!");
					}
				}
				else {
					player.SendMessage("Invalid business.");
				}
			}
			else if(command == "invite") {
				local targetCPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayerByCharName(vargv[1]);
				if(targetCPlayer != null && targetCPlayer.GetID().tointeger() != cPlayer.GetID().tointeger()) {
					
					local isAlreadyInBusiness = false;

					foreach(cPlayerId, memberTable in cPlayer.GetCurrentBusiness().GetMembers()) {
						if(cPlayerId == targetCPlayer.GetID().tointeger()) {
							isAlreadyInBusiness = true;
							break;
						}
					}

					if(!isAlreadyInBusiness) {
						cPlayer.GetCurrentBusiness().AddMember(targetCPlayer.GetID().tointeger(), 2);

						targetCPlayer.SetCurrentBusiness(cPlayer.GetCurrentBusiness());

						CGame.GetDatabase().InsertBusinessMember(targetCPlayer.GetCurrentBusiness().GetID(), targetCPlayer.GetID(), 2);

						targetCPlayer.GetPlayer().SendMessage("You joined " + targetCPlayer.GetCurrentBusiness().GetName());
						cPlayer.SendMessage("Successfully invited " + targetCPlayer.GetCharacterName());
					}
					else {
						cPlayer.GetPlayer().SendMessage("This player is already in your business.");
					}
				}
			}
			else if(command == "remove") {
				local targetCPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayerByCharName(vargv[1]);
				if(targetCPlayer != null && targetCPlayer.GetID().tointeger() != cPlayer.GetID().tointeger()) {
					
					local isInBusiness = false;

					foreach(cPlayerId, memberTable in cPlayer.GetCurrentBusiness().GetMembers()) {
						if(cPlayerId == targetCPlayer.GetID().tointeger()) {
							isInBusiness = true;
							break;
						}
					}

					if(isInBusiness) {
						cPlayer.GetCurrentBusiness().DeleteMember(targetCPlayer.GetID().tointeger());

						targetCPlayer.SetCurrentBusiness(null);

						CGame.GetDatabase().DeleteBusinessMember(targetCPlayer.GetCurrentBusiness().GetID(), targetCPlayer.GetID());

						targetCPlayer.GetPlayer().SendMessage("You have been removed from " + targetCPlayer.GetCurrentBusiness().GetName());
						cPlayer.SendMessage("Successfully removed " + cPlayer.GetCharacterName());
					}
					else {
						cPlayer.GetPlayer().SendMessage("This player is already in your business.");
					}
				}
			}
			else if(command == "additem") {
				local business = cPlayer.GetCurrentBusiness();

				local item = cPlayer.GetInventory().GetItem(vargv[1]);

				if(item) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
					
					if(item.GetQuantity() > 0) {
						local businessItem = business.GetInventory().GetItem(itemTemplate.GetReference());
						if(businessItem) {
							businessItem.SetQuantity(businessItem.GetQuantity() + 1);
							player.SendMessage("Item found, appending");

							//hmmm
							CGame.GetDatabase().UpdateInventoryItem(business.GetInventory().GetID(), businessItem);
						}
						else {
							local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), business.GetInventory().GetID(), 1);
							
							local itemId = CGame.GetDatabase().InsertInventoryItem(business.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), 1);

							newItem.SetID(itemId);
							business.GetInventory().AddItem(newItem);

							player.SendMessage("Item not found, created new item");
						}

						item.SetQuantity(item.GetQuantity() - 1);
						// if quantity == 0, remove item from inventory
						item.CheckValidity(cPlayer.GetInventory().GetID());
					}
					else {
						player.SendMessage("Error, CBusinessScript::Business.AddItem");
					}
				}
				else {
					player.SendMessage("Item not found.");
				}
			}
			else if(command == "takeitem") {
				local business = cPlayer.GetCurrentBusiness();

				local item = business.GetInventory().GetItem(vargv[1]);

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
						item.CheckValidity(business.GetInventory().GetID());
						business.CheckSaleItemValidity();
					}
					else {
						player.SendMessage("Error, CBusinessScript::Business.AddItem");
					}
				}
				else {
					player.SendMessage("Item not found.");
				}
			}
			else if(command == "unsellitem") {
				local business = cPlayer.GetCurrentBusiness();

				local item = business.GetInventory().GetItem(vargv[1]);

				if(business.SaleItemExists(item)) {
					if(item) {
						local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
						
						if(item.GetQuantity() > 0) {
							CGame.GetDatabase().RemoveSaleItem(business.GetID(), item.GetID());

							business.RemoveSaleItem(item);

							player.SendMessage("Removed for sale: " + itemTemplate.GetName());
						}
						else {
							player.SendMessage("Error, CBusinessScript::Business.UnSellItem");
						}
					}
					else {
						player.SendMessage("Item not found.");
					}
				}
				else {
					player.SendMessage("You have not put this item for sale.");
				}
			}				
		}
		else if(vargv.len() == 3) {
			local command = vargv[0];

			if(command == "sellitem") {
				local business = cPlayer.GetCurrentBusiness();

				local item = business.GetInventory().GetItem(vargv[1]);

				if(!business.SaleItemExists(item)) {
					if(item) {
						local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
						
						if(item.GetQuantity() > 0) {
							CGame.GetDatabase().AddSaleItem(business.GetID(), item.GetID(), vargv[2].tointeger(), "Description Here");

							business.AddSaleItem(item, vargv[2].tointeger(), "Description Here");

							player.SendMessage("Put up for sale: " + itemTemplate.GetName());
						}
						else {
							player.SendMessage("Error, CBusinessScript::Business.SellItem");
						}
					}
					else {
						player.SendMessage("Item not found.");
					}
				}
				else {
					player.SendMessage("You have already put this item for sale.");
				}
			}
		}
	}
}
