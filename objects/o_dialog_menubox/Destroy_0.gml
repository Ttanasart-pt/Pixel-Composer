event_inherited();

for( var i = 0, n = array_length(children); i < n; i++ ) 
	instance_destroy(children[i]);

if(instance_number(o_dialog_menubox) == 1)
	FOCUS = FOCUS_BEFORE;