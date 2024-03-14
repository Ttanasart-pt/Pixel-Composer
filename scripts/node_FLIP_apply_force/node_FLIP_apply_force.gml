function FLIP_Obstracle() constructor {
	x = 0;
	y = 0;
	
	texture = noone;
	
	static draw = function() { #region
		if(!is_surface(texture)) return;
		
		var _sw = surface_get_width_safe(texture);
		var _sh = surface_get_height_safe(texture);
		
		draw_surface(texture, x - _sw / 2, y - _sh / 2);
	} #endregion
}

function Node_FLIP_Apply_Force(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Apply Force";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 )	
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 3] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Circle", s_node_shape_type, 1), new scrollItem("Rectangle", s_node_shape_type, 0), ]);
		
	inputs[| 4] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
	
	input_display_list = [ 0, 
		["Collider",	false], 3, 2, 4, 
		["Obstracle",	false], 1, 5, 
	]
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	obstracle = new FLIP_Obstracle();
	index     = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _shp   = getInputData(3);
		var _siz   = getInputData(4);
		var _tex   = getInputData(5);
		
		var _px = _x + _posit[0] * _s;
		var _py = _y + _posit[1] * _s;
		
		var _r = _rad * _s;
		var _w = _siz[0] * _s;
		var _h = _siz[1] * _s;
		
		if(is_surface(_tex)) {
			var _sw = surface_get_width_safe(_tex)  * _s;
			var _sh = surface_get_height_safe(_tex) * _s;
			
			draw_surface_ext(_tex, _px - _sw / 2, _py - _sh / 2, _s, _s, 0, c_white, 1);
		}
		
		draw_set_color(COLORS._main_accent);
		     if(_shp == 0) draw_circle(_px, _py, _r, true);
		else if(_shp == 1) draw_rectangle(_px - _w, _py - _h, _px + _w, _py + _h, true);
		
		if(inputs[| 1].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
		
	} #endregion
	
	static step = function() { #region
		var _shp = getInputData(3);
		
		inputs[| 2].setVisible(_shp == 0);
		inputs[| 4].setVisible(_shp == 1);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _posit = getInputData(1);
		var _rad   = getInputData(2);
		var _shp   = getInputData(3);
		var _siz   = getInputData(4);
		var _tex   = getInputData(5);
		
		obstracle.x       = _posit[0];
		obstracle.y       = _posit[1];
		obstracle.texture = _tex;
		
		if(IS_FIRST_FRAME) {
			index = FLIP_createObstracle(domain.domain);
			array_push(domain.obstracles, obstracle);
		}
		
		     if(_shp == 0) FLIP_setObstracle_circle(domain.domain, index, _posit[0], _posit[1], _rad);
		else if(_shp == 1) FLIP_setObstracle_rectangle(domain.domain, index, _posit[0], _posit[1], _siz[0], _siz[1]);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_add_collider, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}