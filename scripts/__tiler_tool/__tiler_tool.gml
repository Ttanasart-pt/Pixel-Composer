function tiler_tool(node) constructor {
    self.node = node;
    subtool   = 0;
    brush_resizable = true;
	
    apply_draw_surface = noone;
    drawing_surface    = noone;
    preview_draw_mask  = noone;
    
    tile_size   = [ 1, 1 ];
    
    static init = function() {}
    static step = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
    
    static drawPreview = function() {}
    static drawMask    = function() {}
}