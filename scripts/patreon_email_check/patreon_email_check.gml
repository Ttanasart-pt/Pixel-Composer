globalvar PATREON_MAIL_CHECK, PATREON_MAIL_CALLBACK;
globalvar IS_PATREON;

#macro FIRESTORE_ID "pixelcomposer-f9cef"

function patreon_email_check(mail, callback) {
	PATREON_MAIL_CHECK = FirebaseFirestore("memberships").Where("email", "==", mail).Query();
	PATREON_MAIL_CALLBACK = callback;
}

function patreon_create_verification_key(mail, code) {
	var _path = DIRECTORY + "patreon";
	
	var _map = ds_map_create();
	_map[? "mail"] = mail;
	_map[? "code"] = code;
	
	ds_map_secure_save(_map, _path);
}

function __initPatreon() {
	IS_PATREON = false;
	var _path = DIRECTORY + "patreon";
	
	if(!file_exists_empty(_path)) return;
	
	IS_PATREON = _code == _keyTarget;
}
