class CVehicleManager {
	
	vehicles = null;

	constructor() {
		this.vehicles = {};
	}

	function AddVehicle(vehicle) {
		this.vehicles[vehicle.GetVehicle()] <- vehicle;
	}

	function DeleteVehicle(vehicle) {
		delete this.vehicles[vehicle];
	}

	function Exists(vehicle) {
		return this.vehicles.rawin(vehicle);
	}

	function GetVehicle(vehicle) {
		return this.vehicles[vehicle];
	}

	function GetVehicles() {
		return this.vehicles;
	}

}