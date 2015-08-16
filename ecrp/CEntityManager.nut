class CEntityManager {

	playerManager = null;
	inventoryManager = null;
	itemTemplateManager = null;
	vehicleManager = null;
	businessManager = null;
	houseManager = null;

	constructor() {
		this.playerManager = CPlayerManager();
		this.inventoryManager = CInventoryManager();
		this.itemTemplateManager = CItemTemplateManager();
		this.vehicleManager = CVehicleManager();
		this.businessManager = CBusinessManager();
		this.houseManager = CHouseManager();
	}

	function GetPlayerManager() {
		return this.playerManager;
	}

	function GetInventoryManager() {
		return this.inventoryManager;
	}

	function GetItemTemplateManager() {
		return this.itemTemplateManager;
	}

	function GetVehicleManager() {
		return this.vehicleManager;
	}

	function GetBusinessManager() {
		return this.businessManager;
	}

	function GetHouseManager() {
		return this.houseManager;
	}

}