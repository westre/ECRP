function initDatabase() {
	SQLite.Prepare("CREATE TABLE masteraccount (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT DEFAULT NULL, password TEXT DEFAULT NULL, email TEXT DEFAULT NULL, admin_level INTEGER DEFAULT 0, cloud_id INTEGER)").Execute();
	
	SQLite.Prepare("CREATE TABLE account (id INTEGER PRIMARY KEY AUTOINCREMENT, masteraccount_id INTEGER, firstname TEXT, lastname TEXT, experience INTEGER DEFAULT 0, inventory_id INTEGER DEFAULT NULL, political_party_id INTEGER DEFAULT NULL, in_congress INTEGER DEFAULT 0, pos_x REAL, pos_y REAL, pos_z REAL, health INTEGER DEFAULT 100, money INTEGER DEFAULT 500, UNIQUE(id, masteraccount_id))").Execute();
	
	SQLite.Prepare("CREATE TABLE business (id INTEGER PRIMARY KEY AUTOINCREMENT, inventory_id INTEGER, name TEXT, is_public INTEGER DEFAULT 0, is_retail INTEGER DEFAULT 1, is_nationalized INTEGER DEFAULT 0, share_volume INTEGER DEFAULT 0, pos_x REAL, pos_y REAL, pos_z REAL)").Execute();
	SQLite.Prepare("CREATE TABLE business_members (business_id INTEGER, account_id INTEGER, level INTEGER, PRIMARY KEY(business_id, account_id))").Execute();
	SQLite.Prepare("CREATE TABLE business_stock (business_id INTEGER, account_id INTEGER, share_volume INTEGER, PRIMARY KEY(business_id, account_id))").Execute();
	SQLite.Prepare("CREATE TABLE business_stockmarket (business_id INTEGER, account_id INTEGER, share_volume INTEGER, bid INTEGER, price INTEGER, PRIMARY KEY(business_id, account_id))").Execute();
	SQLite.Prepare("CREATE TABLE business_stockmarket_transaction (id INTEGER PRIMARY KEY AUTOINCREMENT, business_id INTEGER, share_volume INTEGER, bid INTEGER, price INTEGER, date INTEGER, seller_account_id INTEGER, buyer_account_id INTEGER)").Execute();
	SQLite.Prepare("CREATE TABLE business_transaction (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, business_id INTEGER, buyer_account_id INTEGER, net INTEGER)").Execute();

	SQLite.Prepare("CREATE TABLE vehicle (id INTEGER PRIMARY KEY AUTOINCREMENT, plate_number INTEGER, account_id INTEGER, inventory_id INTEGER, pos_x REAL, pos_y REAL, pos_z REAL)").Execute();
	
	SQLite.Prepare("CREATE TABLE political_party (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, leader_account_id INTEGER)").Execute();
	
	SQLite.Prepare("CREATE TABLE bill_vote (bill_id INTEGER, account_id INTEGER, vote INTEGER, PRIMARY KEY(bill_id, account_id))").Execute();
	SQLite.Prepare("CREATE TABLE bill (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, content TEXT, key_modifier TEXT DEFAULT NULL, value_modifier TEXT DEFAULT NULL, created_on INTEGER, proposer_account_id INTEGER, is_law INTEGER)").Execute();
	
	SQLite.Prepare("CREATE TABLE inventory (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, max_weight INTEGER)").Execute();
	SQLite.Prepare("CREATE TABLE inventory_item (inventory_id INTEGER, item_id INTEGER, business_item_id INTEGER DEFAULT NULL, PRIMARY KEY(inventory_id, item_id))").Execute();
	SQLite.Prepare("CREATE TABLE business_item (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price INTEGER)").Execute();
	SQLite.Prepare("CREATE TABLE item (id INTEGER PRIMARY KEY AUTOINCREMENT, item_construct_id INTEGER, personal_name TEXT)").Execute();
	SQLite.Prepare("CREATE TABLE item_template (id INTEGER PRIMARY KEY AUTOINCREMENT, item_construct_id INTEGER, name TEXT, weight INTEGER, description TEXT)").Execute();
	SQLite.Prepare("CREATE TABLE item_construct (id INTEGER, item_ability_id INTEGER, PRIMARY KEY(id, item_ability_id))").Execute();
	SQLite.Prepare("CREATE TABLE item_ability (id INTEGER PRIMARY KEY AUTOINCREMENT, ability TEXT, value TEXT, description TEXT)").Execute();
	
	SQLite.Prepare("CREATE TABLE server_modifiers (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT)").Execute();
	SQLite.Prepare("INSERT INTO server_modifiers (key, value) VALUES ('property_tax', '10'), ('tariffs', '10'), ('corporate_tax', '10'), ('sales_tax', '10'), ('income_tax', '10'), ('capital_gains_tax', '10'), ('road_tax', '10'), ('government_money', '100000')").Execute();
}

initDatabase();
