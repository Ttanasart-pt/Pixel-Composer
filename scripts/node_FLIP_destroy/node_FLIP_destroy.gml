function Node_FLIP_Destroy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Destroy Fluid";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	newInput(0, nodeValue_Fdomain("Domain")).setVisible(true, true);
	
	newInput(2, nodeValue_Enum_Scroll( "Shape",  0 , [ new scrollItem("Circle", s_node_shape_circle, 0), new scrollItem("Rectangle", s_node_shape_rectangle, 0), ]));
	newInput(1, nodeValue_Vec2(   "Position",  [ 0, 0 ] )).setHotkey("G").setUnitRef(function() /*=>*/ {return getDimension()});
	newInput(3, nodeValue_Slider( "Radius",      4, [1, 16, 0.1] ));
	newInput(4, nodeValue_Vec2(   "Size",      [ 4, 4 ] ));
	newInput(5, nodeValue_Slider( "Ratio",       1      ));
	// input 6
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = getInputData(1);
		var _shp = getInputData(2);
		var _rad = getInputData(3);
		var _siz = getInputData(4);
		
		var _px = _x + _pos[0] * _s;
		var _py = _y + _pos[1] * _s;
		
		var _r = _rad * _s;
		var _w = _siz[0] * _s;
		var _h = _siz[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		     if(_shp == 0) draw_circle(_px, _py, _r, true);
		else if(_shp == 1) draw_rectangle(_px - _w, _py - _h, _px + _w, _py + _h, true);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {
		var _shp = getInputData(2);
		
		inputs[3].setVisible(_shp == 0);
		inputs[4].setVisible(_shp == 1);
	}
	
	static update = function() { 
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		
		var _pos = getInputData(1);
		var _shp = getInputData(2);
		var _rad = getInputData(3);
		var _siz = getInputData(4);
		var _rat = getInputData(5);
		
		     if(_shp == 0) FLIP_deleteParticle_circle(domain.domain, _pos[0], _pos[1], _rad, _rat);
		else if(_shp == 1) FLIP_deleteParticle_rectangle(domain.domain, _pos[0], _pos[1], _siz[0], _siz[1], _rat);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_flip_destroy, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}