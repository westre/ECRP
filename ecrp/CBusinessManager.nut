class CBusinessManager {
	
	businesses = null;

	constructor() {
		this.businesses = {};
	}

	function AddBusiness(business) {
		this.businesses[business.GetID()] <- business;
	}

	function DeleteBusiness(business) {
		delete this.businesses[business];
	}

	function GetBusiness(business) {
		return this.businesses[business];
	}

	function Exists(business) {
		return this.businesses.rawin(business);
	}

	function GetBusinesses() {
		return this.businesses;
	}

}