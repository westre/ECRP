class CItem {
	
	id = null;
	inventoryId = null;
	itemTemplateId = null;
	quantity = null;
	label = null;

	constructor(itemTemplateId, inventoryId, quantity) {
		this.itemTemplateId = itemTemplateId;
		this.inventoryId = inventoryId;
		this.quantity = quantity;
	}

	function SetID(id) {
		this.id = id;
	}

	function GetID() {
		return this.id;
	}

	function GetInventoryID() {
		return this.inventoryId;
	}

	function GetItemTemplateID() {
		return this.itemTemplateId;
	}

	function SetQuantity(quantity) {
		this.quantity = quantity;
	}

	function GetQuantity() {
		return this.quantity;
	}

	function SetLabel(label) {
		this.label = label;
	}

	function GetLabel() {
		return this.label;
	}

	function Use(cPlayer) {
		local itemTemplate = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(this.itemTemplateId);	

		foreach(itemAbility in itemTemplate.GetAbilities()) {
			if(itemAbility.IsActive() == 1) {
				switch(itemAbility.GetKey()) {
					case "health":					
							cPlayer.GetPlayer().SetHealth(cPlayer.GetPlayer().GetHealth() + itemAbility.GetValue());
							cPlayer.GetPlayer().SendMessage("You feel damn good after eating an apple. Kudos to you for being healthy!");
						break;
					default:
						print("FATAL ERROR:: Invalid item ability");
				}
				this.quantity--;
			}
			else {
				cPlayer.GetPlayer().SendMessage("You can't use a passive item!");
			}			
					
			this.CheckValidity(cPlayer.GetInventory().GetID());
		}
	}

	function CheckValidity(id) {
		if(this.quantity == 0) {
			local inventory = CGame.GetEntityManager().GetInventoryManager().GetInventory(this.inventoryId);
			
			CGame.GetDatabase().DeleteInventoryItem(this.id);
			inventory.DeleteItem(this.id);
		}
		else {
			CGame.GetDatabase().UpdateInventoryItem(id, this);
		}
	}

}