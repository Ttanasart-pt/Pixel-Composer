function canvas_tool() : ToolObject() constructor { 
	rightTools = [];
	brush      = noone;
	drawBrushMask = true;
	
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
	
	tool_after       = noone;
	tool_after_index = undefined;
	
	static setBrush    = function(b) /*=>*/ { brush = b;  return self; }
	static getToolNode = function( ) /*=>*/ {             return self; }
	static setToolAfter= function(t,i=undefined) /*=>*/ { tool_after = t; tool_after_index = i; return self; }
	
	static disable = function() { 
		PANEL_PREVIEW.tool_current = noone; 
		onDisable(); 
		return self; 
	}
	
	static drawPreview     = function( hover, active, _x, _y, _s, _mx, _my ) /*=>*/ {}
	static drawPostOverlay = function( hover, active, _x, _y, _s, _mx, _my ) /*=>*/ {}
	static drawMask        = function( hover, active, _x, _y, _s, _mx, _my ) /*=>*/ {}
}