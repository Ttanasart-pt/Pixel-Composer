function canvas_tool() constructor { 
	
	node = noone;
	rightTools = [];
	
	override = false;
	relative = false;
	
	relative_position  = [ 0, 0 ];
	drawing_surface    = noone;
	canvas_surface     = noone;
	output_surface     = noone;
	apply_draw_surface = noone;
	
	brush_resizable = false;
	mouse_holding   = false;
	
	use_color_3d = false;
	
	subtool = 0;
	
	function setNode(_n) { node = _n; return self; }
	
	function getTool() { return self; }
	
	function disable() { 
		PANEL_PREVIEW.tool_current = noone; 
		onDisable(); 
		return self; 
	}
		
	function onDisable() {}
	
	function init() {}
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	function drawPreview(     hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
	function drawOverlay(     hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
	function drawPostOverlay( hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
	function drawMask(        hover, active, _x, _y, _s, _mx, _my, _snx, _sny ) {}
}