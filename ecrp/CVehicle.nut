class CVehicle {
	
	carId = null;
	inventory = null;
	vehicle = null;
	isLocked = null;

	constructor(carId, inventory, vehicle, isLocked) {
		this.carId = carId;
		this.inventory = inventory;
		this.vehicle = vehicle;
		this.isLocked = isLocked;
	}

	function GetID() {
		return this.carId;
	}

	function GetInventory() {
		return this.inventory;
	}

	function GetVehicle() {
		return this.vehicle;
	}

	function IsLocked() {
		return this.isLocked;
	}
}