globalvar APP_SURF, PRE_APP_SURF, POST_APP_SURF, APP_SURF_OVERRIDE;
APP_SURF      = surface_create(1, 1);
PRE_APP_SURF  = surface_create(1, 1);
POST_APP_SURF = surface_create(1, 1);
APP_SURF_OVERRIDE = false;

function Node_Application_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "GUI Out";
	update_on_frame = true;
	
	newOutput(0, nodeValue_Output("GUI", self, VALUE_TYPE.surface, noone));
	
	APP_SURF_OVERRIDE = true;
	
	static step = function() { #region
		LIVE_UPDATE = true;
	} #endregion
	
	static update = function() { #region
		outputs[0].setValue(PRE_APP_SURF);
	} #endregion
}