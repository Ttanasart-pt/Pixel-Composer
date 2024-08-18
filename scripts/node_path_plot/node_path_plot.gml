function Node_Path_Plot(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Plot Path";
	length = 0;
	setDimension(96, 48);;
	
	newInput(0, nodeValue_Vec2("Output scale", self, [ 8, 8 ]));
	
	inputs[1] = nodeValue_Enum_Scroll("Coordinate", self,  0, [ new scrollItem("Cartesian", s_node_axis_type, 0), 
												 new scrollItem("Polar",     s_node_axis_type, 1),  ]);
	
	eq_type_car = [ "x function", "y function", "parametric" ];
	eq_type_pol = [ "r function", "O function", "parametric" ];
	newInput(2, nodeValue_Enum_Scroll("Equation type", self,  0, eq_type_car));
	
	newInput(3, nodeValue_Text("0 function", self, ""));
	newInput(4, nodeValue_Text("1 function", self, ""));
	
	newInput(5, nodeValue_Vec2("Origin", self, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] ));
		
	newInput(6, nodeValue_Slider_Range("Range", self, [ 0, 1 ], { range: [ -1, 1, 0.01 ] }));
		
	newInput(7, nodeValue_Vec2("Input scale", self, [ 1, 1 ]));
		
	newInput(8, nodeValue_Vec2("Input shift", self, [ 0, 0 ]));
		
	outputs[0] = nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self);
	
	input_display_list = [
		[ "Variable",  false ], 5, 7, 8, 0, 
		[ "Equation",  false ], 1, 2, 3, 4, 6, 
	]
	
	boundary   = new BoundingBox( 0, 0, 1, 1 );
	cached_pos = ds_map_create();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static getLineCount		= function() { return 1; }
	static getSegmentCount	= function() { return 1; }
	
	static getLength		= function(ind = 0) { return length; }
	static getAccuLength	= function(ind = 0) { return [ length ]; }
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _sca  = getInputData(0);
		var _coor = getInputData(1);
		var _eqa  = getInputData(2);
		var _eq0  = getInputData(3);
		var _eq1  = getInputData(4);
		var _orig = getInputData(5);
		var _ran  = getInputData(6);
		var _iran = getInputData(7);
		var _shf  = getInputData(8);
		
		_rat = _ran[0] + (_rat * (_ran[1] - _ran[0]));
		
		switch(_coor) {
			case 0 :
				switch(_eqa) {
					case 0 : 
						out.x = _rat * _iran[0] + _shf[0];
						out.y = evaluateFunction(_eq0, { x: _rat * _iran[0] + _shf[0] });
						break;
					case 1 : 
						out.x = evaluateFunction(_eq0, { y: _rat * _iran[1] + _shf[1] });
						out.y = _rat * _iran[1] + _shf[1];
						break;
					case 2 : 
						out.x = evaluateFunction(_eq0, { t: _rat * _iran[0] + _shf[0] });
						out.y = evaluateFunction(_eq1, { t: _rat * _iran[1] + _shf[1] });
						break;
				}
				break;
			case 1 :
				var _a = new __vec2();
				switch(_eqa) {
					case 0 : 
						_a.x = _rat * _iran[0] + _shf[0];
						_a.y = evaluateFunction(_eq0, { r: _rat * _iran[0] + _shf[0] });
						break;
					case 1 : 
						_a.x = evaluateFunction(_eq0, { O: _rat * _iran[1] + _shf[1] });
						_a.y = _rat * _iran[1] + _shf[1];
						break;
					case 2 : 
						_a.x = evaluateFunction(_eq0, { t: _rat * _iran[0] + _shf[0] });
						_a.y = evaluateFunction(_eq1, { t: _rat * _iran[1] + _shf[1] });
						break;
				}
				
				out.x =  cos(_a.y) * _a.x;
				out.y = -sin(_a.y) * _a.x;
				break;
		}
		
		out.x =  out.x * _sca[0] + _orig[0];
		out.y = -out.y * _sca[1] + _orig[1];
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
	
	static getBoundary		= function() { return boundary; }
	
	static step = function() { 
		var _coor = getInputData(1);
		var _eqa  = getInputData(2);
		
		inputs[2].editWidget.data_list = _coor? eq_type_pol : eq_type_car;
		
		switch(_coor) {
			case 0 :
				switch(_eqa) {
					case 0 : 
						inputs[3].name = "f(x) = ";
						inputs[4].setVisible(false);
						inputs[6].name = "x range";
						break;
					case 1 : 
						inputs[3].name = "f(y) = ";
						inputs[4].setVisible(false);
						inputs[6].name = "y range";
						break;
					case 2 : 
						inputs[3].name = "x(t) = ";
						inputs[4].name = "y(t) = ";
						inputs[4].setVisible(true);
						inputs[6].name = "t range";
						break;
				}
				break;
			case 1 :
				switch(_eqa) {
					case 0 : 
						inputs[3].name = "f(r) = ";
						inputs[4].setVisible(false);
						inputs[6].name = "r range";
						break;
					case 1 : 
						inputs[3].name = "f(O) = ";
						inputs[4].setVisible(false);
						inputs[6].name = "O range";
						break;
					case 2 : 
						inputs[3].name = "r(t) = ";
						inputs[4].name = "O(t) = ";
						inputs[4].setVisible(true);
						inputs[6].name = "t range";
						break;
				}
				break;
		}
	}
	
	static updateBoundary = function() {
		boundary = new BoundingBox( 0, 0, 1, 1 );
		length   = 0;
		
		var sample = 64;
		var op, np;
		
		for( var i = 0; i <= sample; i++ ) {
			np = getPointRatio(i / sample);
			boundary.addPoint(np.x, np.y);
			
			if(i) length += point_distance(op.x, op.y, np.x, np.y);
			
			op = np;
		}
	}
	
	static update = function() { 
		updateBoundary();
		outputs[0].setValue(self); 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}