/// @description Firebase
if(asyncLoad(async_load)) exit;

if (async_load[? "type"] == "FirebaseFirestore_Collection_Query") {
	PATREON_MAIL_CALLBACK(async_load);
	exit;
}