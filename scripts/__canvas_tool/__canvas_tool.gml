function canvas_tool() : ToolObject() constructor { 
	rightTools = [];
	brush      = noone;
	
	override = false;
	relative = false;
	updated  = false;
	
	relative_position  = [ 0, 0 ];
	drawing_surface    = noone;
	canvas_surface     = noone;
	output_surface     = noone;
	apply_draw_surface = noone;
	
	brush_resizable = false;
	mouse_holding   = false;
	
	use_color_3d = false;
	
	subtool = 0;
	pactive = true;
	
	static setBrush = function(b) { brush = b;  return self; }
	static getTool = function()   { return self; }
	
	static disable = function() { 
		PANEL_PREVIEW.tool_current = noone; 
		onDisable(); 
		return self; 
	}
	
	static drawPreview = function(     hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
	static drawPostOverlay = function( hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
	static drawMask = function(        hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
}