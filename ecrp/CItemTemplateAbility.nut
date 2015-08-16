class CItemTemplateAbility {
	
	key = null;
	value = null;
	active = null;

	constructor(key, value, active) {
		this.key = key;
		this.value = value;
		this.active = active;
	}

	function GetKey() {
		return this.key;
	}

	function GetValue() {
		return this.value;
	}

	function IsActive() {
		return this.active;
	}
}