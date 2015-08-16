class CGeneralScript {
	
	name = null;

	constructor(name) {
		this.name = name;

		Command.Add("create", this.CreateCharacter);
		Command.Add("spawn", this.Spawn);
		Command.Add("inventory", this.Inventory);
		Command.Add("i", this.Inventory);
		Command.Add("apple", this.Apple);
		Command.Add("save", this.Save);
		Command.Add("use", this.UseItem);
		Command.Add("general", this.General);
		Command.Add("help", this.Help);
		
		Command.Add("itemoffer", this.ItemOffer);
		Command.Add("acceptoffer", this.AcceptOffer);
		Command.Add("declineoffer", this.DeclineOffer);
		Command.Add("canceloffer", this.CancelOffer);

		Command.Add("store", this.Store);
		Command.Add("buy", this.Buy);
	}

	function General(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 1) {
			local command = vargv[0];

			if(command == "help") {
				player.SendMessage("/create #ccccccCreates a character");
				player.SendMessage("/spawn #ccccccSpawns a character");
				player.SendMessage("/i(nventory) #ccccccShows inventory");
				player.SendMessage("/use #ccccccUses an item");
				player.SendMessage("/itemoffer #ccccccOffers an item to a player");
				player.SendMessage("/acceptoffer #ccccccAccepts the proposal");
				player.SendMessage("/declineoffer #ccccccDeclines the proposal");
				player.SendMessage("/canceloffer #ccccccCancels the proposal");
				player.SendMessage("/store #ccccccOpens inventory of a business");
				player.SendMessage("/buy [item] #ccccccBuys an item from a business");
			}
		}
	}

	function Help(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		foreach(script in cPlayer.GetScriptSets()) {
			player.SendMessage("#cccccc/" + script + " help");
		}		
	}

	function CreateCharacter(player, command, ...) {	
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 1) {
			local inventory = CGame.GetDatabase().CreateInventory(vargv[0] + "s inventory", 50);			
			CGame.GetEntityManager().GetInventoryManager().AddInventory(inventory[0], CInventory(inventory[0], inventory[1], inventory[2]));

			CGame.GetDatabase().CreateAccount(cPlayer, vargv[0], inventory[0]);

			player.SendMessage("#00ff00Your character #ffffff'" + vargv[0] + "' #00ff00has been created.");
			cPlayer.RefreshAccounts();
		}
		else {
			player.SendMessage("It's /create [name].");
		}
	}

	function Spawn(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 1) {
			local characterId = vargv[0];			
			local isOwner = false;

			foreach(id in cPlayer.GetCharacters()) {
				if(id == characterId) {
					isOwner = true;
					break;
				}
			}

			if(isOwner) {
				local characterData = CGame.GetDatabase().GetCharacter(characterId);
				cPlayer.SetID(characterData.id);
				cPlayer.SetCharacterName(characterData.name);
				cPlayer.SetExperience(characterData.experience);
				cPlayer.SetInventory(CGame.GetEntityManager().GetInventoryManager().GetInventory(characterData.inventory_id));

				if((characterData.pos_x && characterData.pos_y && characterData.pos_z && characterData.heading) == 0) {
					player.SetSpawnPosition(-229.635574, 431.741943, 14.742328);
					player.SetSpawnHeading(102.232361);
					player.Spawn(-229.635574, 431.741943, 14.742328, 102.232361);
					player.SetPosition(-229.635574, 431.741943, 14.742328);

					local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("apple").GetID(), cPlayer.GetInventory().GetID(), 3);		
					local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("apple").GetID(), 3);

					newItem.SetID(itemId);
					cPlayer.GetInventory().AddItem(newItem);

					player.SendMessage("Citizen, welcome to Empire City!");

					// BETA STUFF, PREVIEW ONLY!
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

					player.SendMessage("You have been given a personal key for your car.");

					player.PutInVehicle(vehicleRef, 0);

					CGame.GetDatabase().SavePlayer(cPlayer);
					// END OF BETA STUFF!
				}
				else {
					player.SetSpawnPosition(characterData.pos_x.tofloat(), characterData.pos_y.tofloat(), characterData.pos_z.tofloat());
					player.SetSpawnHeading(characterData.heading.tofloat());
					player.Spawn(characterData.pos_x.tofloat(), characterData.pos_y.tofloat(), characterData.pos_z.tofloat(), characterData.heading.tofloat());
					player.SetPosition(characterData.pos_x.tofloat(), characterData.pos_y.tofloat(), characterData.pos_z.tofloat());
					
					player.SendMessage("Citizen, welcome back to Empire City!");

					foreach(business in CGame.GetEntityManager().GetBusinessManager().GetBusinesses()) {
						foreach(cPlayerId, memberTable in business.GetMembers()) {
							if(cPlayerId == cPlayer.GetID().tointeger()) {
								player.SendMessage("#00ffffBUSINESS: #ffffffYou are level " + memberTable.level + " in " + business.GetName());

								if(!cPlayer.HasPermission("business")) cPlayer.GrantScriptSet("business");
								if(!cPlayer.HasPermission(business.GetScriptSet())) cPlayer.GrantScriptSet(business.GetScriptSet());
							}
						}
					}

					foreach(house in CGame.GetEntityManager().GetHouseManager().GetHouses()) {
						if(cPlayer.GetID().tointeger() == house.GetOwnerID().tointeger()) {
							player.SendMessage("#00ff00HOUSE: #ffffff" + house.GetName());
						}
					}
				}
 
				if(characterData.current_business_id != 0) {
					cPlayer.SetCurrentBusiness(CGame.GetEntityManager().GetBusinessManager().GetBusiness(characterData.current_business_id));
					player.SendMessage("Your selected business: " + cPlayer.GetCurrentBusiness().GetName());
				}

				// BETA STUFF
				player.GiveWeapon(7, 100, true);
				// END OF BETA

				cPlayer.GrantScriptSet("roleplay");
				cPlayer.SetLoggedIn(true);

				player.SendMessage("#00ff00For help & commands type in: #ffffff/help");
			}
			else {
				player.SendMessage("#ff0000You are not the owner of this character.");
			}
		}
		else {
			player.SendMessage("It's /spawn [id].");
		}
	}

	function Inventory(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		player.SendMessage("#00ffff------[" + cPlayer.GetInventory().GetName() + "(" + cPlayer.GetInventory().GetCurrentWeight() + "/" + cPlayer.GetInventory().GetMaxWeight() + ")]------");
		foreach(item in cPlayer.GetInventory().GetItems()) {
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

	function ItemOffer(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 2) {
			local target = vargv[0];
			local item = vargv[1];

			local targetCPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayerByCharName(target);

			if(targetCPlayer != null) {
				local inventoryItem = cPlayer.GetInventory().GetItem(item);
				
				if(inventoryItem != false) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(inventoryItem.GetItemTemplateID());
					if(!targetCPlayer.HasItemOfferPending()) {
						if(!cPlayer.HasSentItemOffer()) {
							targetCPlayer.SetItemOffer(cPlayer, inventoryItem);
						
							targetCPlayer.GetPlayer().SendMessage("---------[TRADE OFFER]---------");
							targetCPlayer.GetPlayer().SendMessage("Sent by: #00ff00" + cPlayer.GetCharacterName());
							targetCPlayer.GetPlayer().SendMessage("Item: #" + itemTemplate.GetColor() + itemTemplate.GetName() + " #cccccc[" + itemTemplate.GetQualityName() + "]");
							if(itemTemplate.GetAbilities().len() > 0) {
								foreach(itemAbility in itemTemplate.GetAbilities()) {
									if(itemAbility.IsActive().tointeger() == 1)
										player.SendMessage("Ability: #00ff00" + itemAbility.GetKey() + ":" + itemAbility.GetValue() + " #ccccccACTIVE");
									else if(itemAbility.IsActive().tointeger() == 0)
										player.SendMessage("Ability: #ff0000" + itemAbility.GetKey() + ":" + itemAbility.GetValue() + " #ccccccPASSIVE");
								}
							}
							else {
								player.SendMessage("#0000ff- undefined, please report to dev");
							}
							targetCPlayer.GetPlayer().SendMessage("--------------------------------");
							targetCPlayer.GetPlayer().SendMessage("Type #00ff00/acceptoffer #ffffffor #ff0000/declineoffer #ffffffto accept/decline said offer.");
							
							targetCPlayer.SetItemOfferPending(true);

							cPlayer.GetPlayer().SendMessage("You have sent a trade proposal to " + targetCPlayer.GetCharacterName());
							cPlayer.SetSentItemOffer(true);
							cPlayer.SetSentItemOfferPlayer(targetCPlayer);
						}
						else {
							player.SendMessage("Please cancel your current trade offer. /canceloffer");
						}
					}
					else {
						player.SendMessage("This player has a trade offer pending.");
						targetCPlayer.GetPlayer().SendMessage("New trade offer has been auto declined, because you already have a pending trade offer.");
						targetCPlayer.GetPlayer().SendMessage("Declined offer from: " + cPlayer.GetCharacterName());
					}
				}
				else {
					player.SendMessage("#ff0000Invalid item. Make sure you use the right item reference!");
				}
			}
			else {
				player.SendMessage("#ff0000Invalid name. Make sure you use the character name!");
			}
		}
		else {
			player.SendMessage("It's /itemoffer [charactername] [item]");
		}		
	}

	function AcceptOffer(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(cPlayer.HasItemOfferPending()) {
			local offerPlayer = cPlayer.GetItemOffer().origin;
			if(offerPlayer != null && CGame.GetEntityManager().GetPlayerManager().ExistsByID(offerPlayer.GetID())) {
				local item = cPlayer.GetItemOffer().item;

				local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());

				if(item.GetQuantity() > 0) {
					local myItem = cPlayer.GetInventory().GetItem(itemTemplate.GetReference());
					if(myItem) {
						myItem.SetQuantity(myItem.GetQuantity() + 1);
						player.SendMessage("Item found, appending");
						CGame.GetDatabase().UpdateInventoryItem(cPlayer.GetInventory().GetID(), myItem);
					}
					else {
						local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), cPlayer.GetInventory().GetID(), 1);
						
						local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemTemplate.GetReference()).GetID(), 1);

						newItem.SetID(itemId);
						cPlayer.GetInventory().AddItem(newItem);

						player.SendMessage("Item not found, created new item");
					}

					item.SetQuantity(item.GetQuantity() - 1);
					item.CheckValidity(cPlayer);

					cPlayer.SetItemOfferPending(false);
					offerPlayer.SetSentItemOffer(false);

					offerPlayer.GetPlayer().SendMessage("Trade successful");
				}
				else {
					player.SendMessage("This proposal is no longer valid. The proposer doesn't have the item anymore!");
					offerPlayer.GetPlayer().SendMessage("Your proposal has been declined for: no item available.");
				}
			}
			else {
				player.SendMessage("Invalid player instance, offline maybe?");
				cPlayer.SetItemOfferPending(false);
			}
		}
		else {
			player.SendMessage("You don't have an offer pending.");
		}
	}

	function DeclineOffer(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(cPlayer.HasItemOfferPending()) {
			local offerPlayer = cPlayer.GetItemOffer().origin;
			if(offerPlayer != null && CGame.GetEntityManager().GetPlayerManager().ExistsByID(offerPlayer.GetID())) {
				cPlayer.SetItemOfferPending(false);
				offerPlayer.SetSentItemOffer(false);

				player.SendMessage("Declined proposal.");
				offerPlayer.GetPlayer().SendMessage("Your proposal has been denied.");
			}
			else {
				player.SendMessage("Invalid player instance, offline maybe?");
				cPlayer.SetItemOfferPending(false);
			}
		}
		else {
			player.SendMessage("You don't have an offer pending.");
		}
	}

	function CancelOffer(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(cPlayer.HasSentItemOffer()) {
			local targetPlayer = cPlayer.GetSentItemOfferPlayer();

			if(targetPlayer != null && CGame.GetEntityManager().GetPlayerManager().ExistsByID(targetPlayer.GetID())) {
				targetPlayer.SetItemOfferPending(false);
				cPlayer.SetSentItemOffer(false);

				player.SendMessage("Cancelled proposal.");
				targetPlayer.GetPlayer().SendMessage("The proposal has been cancelled.");
			}
			else {
				player.SendMessage("Invalid player instance, offline maybe?");
				cPlayer.SetSentItemOffer(false);
			}
		}
		else {
			player.SendMessage("You don't have an offer pending.");
		}
	}

	function Apple(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		local item = cPlayer.GetInventory().GetItem("apple");
		
		if(item) {
			item.SetQuantity(item.GetQuantity() + 1);
			player.SendMessage("You've got an extra fuel! Qty: " + item.GetQuantity());
			CGame.GetDatabase().UpdateInventoryItem(cPlayer.GetInventory().GetID(), item);
		}
		else {
			local newItem = CItem(CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("apple").GetID(), cPlayer.GetInventory().GetID(), 1);
			
			local itemId = CGame.GetDatabase().InsertInventoryItem(cPlayer.GetInventory().GetID(), CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate("apple").GetID(), 1);

			newItem.SetID(itemId);
			cPlayer.GetInventory().AddItem(newItem);

			player.SendMessage("Since you don't even have an fuel, here you go!");
		}
	}

	function Save(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		CGame.GetDatabase().SavePlayer(cPlayer);
	}

	function UseItem(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 1) {
			local item = cPlayer.GetInventory().GetItem(vargv[0]);
		
			if(item) {
				local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
				if(itemTemplate.GetAbilities().len() > 0) {
					item.Use(cPlayer);
				}
				else {
					player.SendMessage("This is a passive item!");
				}
			}
			else {
				player.SendMessage("Item not found.");
			}
		}
		else {
			player.SendMessage("It's /use [name]");
		}	
		
	}

	function Store(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		foreach(business in CGame.GetEntityManager().GetBusinessManager().GetBusinesses()) {
			if(cPlayer.GetDistanceBetweenXYZ(business.GetPosX(), business.GetPosY(), business.GetPosZ()) <= 5) {
				player.SendMessage("#00ffff------[" + business.GetName() + "]------");
				foreach(item, saleItem in business.GetSaleItems()) {
					local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
					player.SendMessage("[$" + saleItem.price + "/Stock: " + item.GetQuantity() + "] " + itemTemplate.GetName() + "#cccccc (/buy " + itemTemplate.GetReference() + ")");
				}
				player.SendMessage("#00ffff------------");
				break;
			}
		}
	}

	function Buy(player, command, ...) {
		local cPlayer = CGame.GetEntityManager().GetPlayerManager().GetPlayer(player);
		if(!cPlayer.HasPermission("general")) return true;

		if(vargv.len() == 1) {
			foreach(business in CGame.GetEntityManager().GetBusinessManager().GetBusinesses()) {
				if(cPlayer.GetDistanceBetweenXYZ(business.GetPosX(), business.GetPosY(), business.GetPosZ()) <= 5) {
					local item = business.GetInventory().GetItem(vargv[0]);
					if(item) {
						if(business.SaleItemExists(item)) {
							local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID());
							player.SendMessage("You wish to buy: " + itemTemplate.GetName());

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
							player.SendMessage("This item is not for sale!");
						}
					}
					else {
						player.SendMessage("Item not found.");
					}
				}
			}
		}
	}
}
