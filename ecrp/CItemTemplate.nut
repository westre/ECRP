class CItemTemplate {
	
	id = null;
	name = null;
	reference = null;
	qualityId = null;
	description = null;
	weight = null;
	qualityName = null;
	color = null;
	abilities = null;

	constructor(id, name, reference, qualityId, description, weight, qualityName, color) {
		this.id = id;
		this.name = name;
		this.reference = reference;
		this.qualityId = qualityId;
		this.description = description;
		this.weight = weight;
		this.qualityName = qualityName;
		this.color = color;
		this.abilities = [];
	}

	function AddAbility(ability) {
		this.abilities.push(ability);
	}

	function GetAbilities() {
		return this.abilities;
	}

	function GetID() {
		return this.id;
	}

	function GetName() {
		return this.name;
	}

	function GetReference() {
		return this.reference;
	}

	function GetQualityID() {
		return this.qualityId;
	}

	function GetDescription() {
		return this.description;
	}

	function GetWeight() {
		return this.weight;
	}

	function GetQualityName() {
		return this.qualityName;
	}

	function GetColor() {
		return this.color;
	}

}