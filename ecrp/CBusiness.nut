class CBusiness {
	
	id = null;
	inventory = null;
	name = null;
	posX = null;
	posY = null;
	posZ = null;
	isLocked = null;
	members = null;
	scriptSet = null;
	saleItems = null;

	constructor(id, inventory, name, posX, posY, posZ, isLocked, scriptSet) {
		this.id = id;
		this.inventory = inventory;
		this.name = name;
		this.posX = posX;
		this.posY = posY;
		this.posZ = posZ;
		this.scriptSet = scriptSet;
		this.members = {};
		this.saleItems = {};
	}

	function GetID() {
		return this.id;
	}

	function GetInventory() {
		return this.inventory;
	}

	function GetName() {
		return this.name;
	}

	function GetPosX() {
		return this.posX;
	}

	function GetPosY() {
		return this.posY;
	}

	function GetPosZ() {
		return this.posZ;
	}

	function GetMembers() {
		return this.members;
	}

	function AddMember(cPlayerId, level) {
		this.members[cPlayerId] <- {};
		this.members[cPlayerId].level <- level;
	}

	function DeleteMember(cPlayerId) {
		delete this.members[cPlayerId];
	}

	function GetScriptSet() {
		return this.scriptSet;
	}

	function AddSaleItem(item, price, description) {
		this.saleItems[item] <- {};
		this.saleItems[item].price <- price;
		this.saleItems[item].description <- description;
	}

	function RemoveSaleItem(item) {
		delete this.saleItems[item];
	}

	function SaleItemExists(item) {
		return this.saleItems.rawin(item);
	}

	function GetSaleItems() {
		return this.saleItems;
	}

	function CheckSaleItemValidity() {
		foreach(item, saleItem in this.saleItems) {
			if(item.GetQuantity() == 0) {
				delete this.saleItems[item];
				print("CBusiness::CheckSaleItemValidity() Removed sale item.");
			}
		}
	}
}