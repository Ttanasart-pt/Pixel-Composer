/// @description Firebase
if(asyncLoad(async_load, "listener", "social")) exit;

var ev_id   = async_load[? "id"];
var ev_type = async_load[? "type"];
var ev_list = async_load[? "listener"];

if (ev_list == PATREON_MAIL_CHECK && ev_type == "FirebaseFirestore_Collection_Query") {
	PATREON_MAIL_CALLBACK(async_load);
	exit;
}