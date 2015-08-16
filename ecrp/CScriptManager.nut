class CScriptManager {

	scripts = null;

	constructor() {
		this.scripts = {};

		this.scripts["general"] <- CGeneralScript("general");
		this.scripts["roleplay"] <- CRoleplayScript("roleplay");
		this.scripts["developer"] <- CDeveloperScript("developer");
		this.scripts["business"] <- CBusinessScript("business");
		this.scripts["vehicle"] <- CVehicleScript("vehicle");
	}

	function GetScript(name) {
		return this.scripts[name];
	}

}