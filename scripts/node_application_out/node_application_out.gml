globalvar APP_SURF, PRE_APP_SURF, POST_APP_SURF, APP_SURF_OVERRIDE;
APP_SURF      = -1;
PRE_APP_SURF  = -1;
POST_APP_SURF = -1;
APP_SURF_OVERRIDE = false;

function Node_Application_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "GUI Out";
	update_on_frame = true;
	
	newOutput(0, nodeValue_Output("GUI", self, VALUE_TYPE.surface, noone));
	
	APP_SURF_OVERRIDE = true;
	
	static step = function() {
		LIVE_UPDATE = true;
	}
	
	static update = function() {
		outputs[0].setValue(PRE_APP_SURF);
	}
}