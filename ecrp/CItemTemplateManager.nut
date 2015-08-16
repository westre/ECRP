class CItemTemplateManager {
	
	itemTemplates = null;

	constructor() {
		this.itemTemplates = {};
	}

	function AddItemTemplate(itemTemplate) {
		this.itemTemplates[itemTemplate.GetReference()] <- itemTemplate;

		//print("[Reference: " + itemTemplate.GetReference() + "] ItemTemplate added");
	}

	function DeleteItemTemplate(reference) {
		delete this.itemTemplates[reference];
	}

	function GetItemTemplate(reference) {
		return this.itemTemplates[reference];
	}

	function GetItemTemplateByID(id) {
		foreach(itemTemplate in this.itemTemplates) {
			if(id.tointeger() == itemTemplate.GetID().tointeger())
				return itemTemplate;
		}

		return null;
	}

	function Exists(reference) {
		return this.itemTemplates.rawin(reference);
	}

	function GetItemTemplates() {
		return this.itemTemplates;
	}

}