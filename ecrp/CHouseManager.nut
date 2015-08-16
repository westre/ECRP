class CHouseManager {
	
	houses = null;

	constructor() {
		this.houses = {};
	}

	function AddHouse(house) {
		this.houses[house.GetID()] <- house;
	}

	function DeleteHouse(house) {
		delete this.houses[house];
	}

	function GetHouse(house) {
		return this.houses[house];
	}

	function Exists(house) {
		return this.houses.rawin(house);
	}

	function GetHouses() {
		return this.houses;
	}

}