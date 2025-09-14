globalvar PATREON_MAIL_CHECK;    PATREON_MAIL_CHECK    = undefined;
globalvar PATREON_MAIL_CALLBACK; PATREON_MAIL_CALLBACK = undefined;
globalvar IS_PATREON;            IS_PATREON            = false;

#macro FIRESTORE_ID "pixelcomposer-f9cef"

function cmd_program_patreon_legacy(mail) : cmd_program() constructor {
	title = "Patreon";
	color = CDEF.pink;
	
	array_push(CMD, cmdLine($"Patreon legacy verifier", CDEF.pink) );
	array_push(CMD, cmdLine($"> Checking email: {mail}", COLORS._main_text_sub) );
	
	mail_checking = true;
	
	function mailCallback(response) {
		mail_checking = false;
		
		if (response[? "status"] != 200) {
			array_push(CMD, cmdLine($"X Request error.", COLORS._main_value_negative) );
			CMDPRG = noone;
			return;
		}
		
		var val = response[? "value"];
		var map = json_try_parse(val);
		
		var keys = struct_get_names(map);
		if(array_empty(keys)) {
			array_push(CMD, cmdLine($"X Patreon email not found.", COLORS._main_value_negative) );
			CMDPRG = noone;
			return;
		}
		
		var key    = keys[0];
		var member = map[$ key];
		var stat   = string_replace_all(string_lower(member.status), " ", "_");
		
		if(string_pos("active", stat) > 0) {
			var _mail   = member.email;
			var _code   = patreon_generate_activation_key(_mail); //yea we doing this on client now. 
			global.PATREON_VERIFY_CODE = _code;
			
			var _map = ds_map_create();
			
			_map[? "Api-Token"]    = global.PATREON_EMAIL_TOKENS;
			_map[? "Content-Type"] = "application/json";
			
			var _body = {
				from: {
				    email: "verify@pixel-composer.com",
				    name: "Pixel Composer"
				},
				to: [ { email: _mail } ],
				template_uuid: "82b77e89-0343-4a20-a63d-063f4f8dcdfe",
				template_variables: { verification_code: _code }
			};
			
			http_request("https://send.api.mailtrap.io/api/send", "POST", _map, json_stringify(_body));
			array_push(CMD, cmdLine($"> Verification code has been send to your email.", COLORS._main_text_sub) );
			array_push(CMD, cmdLine($"> Enter verification code: ", COLORS._main_text) );
			
		} else {
			array_push(CMD, cmdLine($"X Patreon membership not active.", COLORS._main_value_negative) );
			CMDPRG = noone;
			
		}
	}
	
	patreon_email_check(mail, mailCallback);
	
	static submit = function(arg) { 
		if(arg == global.PATREON_VERIFY_CODE) {
			array_push(CMD, cmdLine($"> Patreon verified, thank you for suporting Pixel Composer!", COLORS._main_value_positive) );
			return 1;
			
		} else {
			array_push(CMD, cmdLine($"> Incorrect code, please try again.", COLORS._main_value_negative) );
			array_push(CMD, cmdLine($"> Enter verification code: ", COLORS._main_text) );
			return 0;
			
		}
		
		return 0; 
	}
}

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

function patreon_create_verification_code(code) {
	var _path = DIRECTORY + "patreon";
	
	var _map = ds_map_create();
	_map[? "code"] = code;
	
	ds_map_secure_save(_map, _path);
	IS_PATREON = true;
}

function patreon_generate_activation_key(_mail) {
	var token = string(global.PATREON_ACTIVATION_KEYS, _mail);
	return sha1_string_utf8(token);
}