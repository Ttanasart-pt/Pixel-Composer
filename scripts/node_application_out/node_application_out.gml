globalvar APP_SURF, PRE_APP_SURF, POST_APP_SURF, APP_SURF_OVERRIDE;
APP_SURF      = surface_create(1, 1);
PRE_APP_SURF  = surface_create(1, 1);
POST_APP_SURF = surface_create(1, 1);
APP_SURF_OVERRIDE = false;

function Node_Application_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "GUI Out";
	update_on_frame = true;
	
	outputs[| 0] = nodeValue("GUI", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static step = function() { #region
		outputs[| 0].setValue(PRE_APP_SURF);
	} #endregion
}