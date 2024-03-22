function Node_FLIP_Destroy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Destroy Fluid";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	w     = 96;
	min_h = 96;
	
	manual_ungroupable = false;
	
	inputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.input, VALUE_TYPE.fdomain, noone )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(); });
	
	inputs[| 2] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Circle", s_node_shape_type, 1), new scrollItem("Rectangle", s_node_shape_type, 0), ]);
		
	inputs[| 3] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4 )	
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
		
	inputs[| 4] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue("Ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1 )
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Domain", self, JUNCTION_CONNECT.output, VALUE_TYPE.fdomain, noone );
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
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
		
		if(inputs[| 1].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny)) active = false;
		
	} #endregion
	
	static step = function() { #region
		var _shp = getInputData(2);
		
		inputs[| 3].setVisible(_shp == 0);
		inputs[| 4].setVisible(_shp == 1);
	} #endregion
	
	static update = function() { #region 
		var domain = getInputData(0);
		if(!instance_exists(domain)) return;
		
		outputs[| 0].setValue(domain);
		
		var _pos = getInputData(1);
		var _shp = getInputData(2);
		var _rad = getInputData(3);
		var _siz = getInputData(4);
		var _rat = getInputData(5);
		
		     if(_shp == 0) FLIP_deleteParticle_circle(domain.domain, _pos[0], _pos[1], _rad, _rat);
		else if(_shp == 1) FLIP_deleteParticle_rectangle(domain.domain, _pos[0], _pos[1], _siz[0], _siz[1], _rat);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_fluidSim_destroy_fluid, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewValues = function() { var domain = getInputData(0); return instance_exists(domain)? domain.domain_preview : noone; }
}