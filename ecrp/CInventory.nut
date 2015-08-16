class CInventory {
	
	id = null;
	name = null;
	maxWeight = null;
	items = null;

	constructor(id, name, maxWeight) {
		this.id = id;
		this.name = name;
		this.maxWeight = maxWeight;
		this.items = [];
	}

	function GetID() {
		return this.id;
	}

	function GetName() {
		return this.name;
	}

	function GetMaxWeight() {
		return this.maxWeight;
	}

	function AddItem(item) {
		this.items.push(item);
	}

	function GetCurrentWeight() {
		local weight = 0;
		foreach(item in this.items) {
			weight += (CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplateByID(item.GetItemTemplateID()).GetWeight() * item.GetQuantity());
		}
		return weight;
	}

	function GetItem(itemReference) {
		foreach(item in this.items) {
			if(CGame.GetEntityManager().GetItemTemplateManager().Exists(itemReference)) {
				local neededItemId = CGame.GetEntityManager().GetItemTemplateManager().GetItemTemplate(itemReference).GetID();

				if(item.GetItemTemplateID() == neededItemId) {
					return item;
				}
			}
		}
		return false;
	}

	function GetItemByID(id) {
		foreach(item in this.items) {
			if(item.GetID().tointeger() == id) {
				return item;
			}
		}
		return false;
	}

	function DeleteItem(itemId) {
		for(local index = 0; index < this.items.len(); index++) {
			if(itemId == this.items[index].GetID()) {
				this.items.remove(index);
				break;
			}
		}
	}

	function GetItems() {
		return this.items;
	}
}