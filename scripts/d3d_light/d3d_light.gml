function __3dLight() : __3dObject() constructor {
	UI_vertex = [];
	for( var i = 0; i <= 32; i++ ) UI_vertex[i] = [ 0, lengthdir_x(0.5, i / 32 * 360), lengthdir_y(0.5, i / 32 * 360), c_yellow, 0.8 ];
	VB_UI = build(noone, UI_vertex);
	
	color = c_white;
	intensity = 1;
	
	static submit    = function(params = {}, shader = noone) {}
}