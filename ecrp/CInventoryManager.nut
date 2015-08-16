class CInventoryManager {
	
	inventories = null;

	constructor() {
		this.inventories = {};
	}

	function AddInventory(inventoryId, inventory) {
		this.inventories[inventoryId] <- inventory;
	}

	function DeleteInventory(inventory) {
		delete this.inventories[inventory];
	}

	function GetInventory(inventory) {
		return this.inventories[inventory];
	}

	function GetInventories() {
		return this.inventories;
	}
}