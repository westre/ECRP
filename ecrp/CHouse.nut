class CHouse {
	
	id = null;
	cPlayerOwnerId = null;
	inventory = null;
	name = null;
	posX = null;
	posY = null;
	posZ = null;
	isLocked = null;

	constructor(id, inventory, cPlayerOwnerId, name, posX, posY, posZ, isLocked) {
		this.id = id;
		this.inventory = inventory;
		this.cPlayerOwnerId = cPlayerOwnerId;
		this.name = name;
		this.posX = posX;
		this.posY = posY;
		this.posZ = posZ;
		this.isLocked = isLocked;
	}

	function GetID() {
		return this.id;
	}

	function GetInventory() {
		return this.inventory;
	}

	function GetOwnerID() {
		return this.cPlayerOwnerId;
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

	function IsLocked() {
		return this.isLocked;
	}

}