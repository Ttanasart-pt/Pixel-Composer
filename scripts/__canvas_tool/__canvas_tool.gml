function canvas_tool() constructor { 
	
	node = noone;
	relative = false;
	
	relative_position  = [ 0, 0 ];
	drawing_surface    = noone;
	_canvas_surface    = noone;
	apply_draw_surface = noone;
	
	brush_resizable = false;
	mouse_holding   = false;
	
	function step(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	function drawPreview(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	function drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	function drawPostOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
}