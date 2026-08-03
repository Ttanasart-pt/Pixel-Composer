function canvas_s_tool() constructor {
	icon       = undefined;
	tooltip    = "";
	hotkey     = undefined;
	isDrawer   = false;
	isSelector = false;
	
	overrideColor = false;
	overrideLayer = false;
	
	hover = false;
	focus = false;
	
	preview_override = undefined;
	preview_x = 0;
	preview_y = 0;
	preview_s = 0;
	
	mx = 0;
	my = 0;
	
	canvas = undefined;
	erase  = false;
	
	content_surface = undefined;
	
	////- Settings
	
	settings = [];
	
	////- Functions
	
	function init(_node) {}
	function destroy()   {}
	
	function step(_hover, _focus, _preview_x, _preview_y, _preview_s, _mx, _my) { 
		hover = _hover;
		focus = _focus;
		
		preview_x = _preview_x;
		preview_y = _preview_y;
		preview_s = _preview_s;
		
		mx = _mx;
		my = _my;
	}
	
	////- Draw
	
	function drawBrush(_brushSurface) { return undefined; }
	function drawing(_drawingSurface) {}
	
	function drawOutline(_x, _y, _s) {}
	
}