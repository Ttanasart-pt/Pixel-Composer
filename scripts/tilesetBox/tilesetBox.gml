function tilesetBox(_junction) : widget() constructor {
	self.junction = _junction;
	
    b_newTileset = button(function() /*=>*/ { 
    	var b = nodeBuild("Node_Tile_Tileset", junction.node.x - 160, junction.node.y);
    	junction.setFrom(b.outputs[0]);
	});
	
	b_newTileset.text = __txt("New tileset");
    
	static trigger = function() { }
	
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _tileset, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = TEXTBOX_HEIGHT;
        
        if(_tileset == noone) {
            b_newTileset.setFocusHover(active, hover);
            var param = new widgetParam(x, y, w, h, noone, {}, _m, rx, ry);
            b_newTileset.drawParam(param);
            
        } else {
            draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, x, y, w, h, COLORS._main_icon_light);
        }
        
		return h;
	}
	
	static clone = function() { return new outputBox(); }
}
