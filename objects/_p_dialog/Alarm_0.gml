/// @description init
resetPosition();
if(USE_TEXTUREGROUP && texturegroup_get_status("UI") == texturegroup_status_loading) {
	alarm[0] = 1;
	exit;
}

if(sHOVER) init_rclick = false;
ready = true;