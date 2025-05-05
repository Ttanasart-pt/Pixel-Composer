function Node_Path_Plot(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Plot Path";
	length = 0;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Output scale", self, [ 8, 8 ]));
	
	newInput(1, nodeValue_Enum_Scroll("Coordinate", self,  0, [ new scrollItem("Cartesian", s_node_axis_type, 0), 
												                new scrollItem("Polar",     s_node_axis_type, 1),  ]));
	
	eq_type_car = [ "x function", "y function", "parametric" ];
	eq_type_pol = [ "r function", "O function", "parametric" ];
	newInput(2, nodeValue_Enum_Scroll("Equation type", self,  0, eq_type_car));
	
	newInput(3, nodeValue_Text("0 function", self, ""));
	newInput(4, nodeValue_Text("1 function", self, ""));
	
	newInput(5, nodeValue_Vec2("Origin", self, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] ));
		
	newInput(6, nodeValue_Slider_Range("Range", self, [ 0, 1 ], { range: [ -1, 1, 0.01 ] }));
		
	newInput(7, nodeValue_Vec2("Input Scale", self, [ 1, 1 ]));
	
	newInput(8, nodeValue_Vec2("Input Shift", self, [ 0, 0 ]));
	
	newInput(9, nodeValue_Bool("Use Weight", self, false));
	
	newInput(10, nodeValue_Text("w(x)", self, ""));
	
	newInput(11, nodeValue_Text("z(x)", self, ""));
	
	newInput(12, nodeValue_Bool("3D", self, false));
	
	newOutput(0, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, self));
	
	input_display_list = [
		[ "Variable",  false],     5, 7, 8, 0, 
		[ "Equation",  false],     1, 2, 3, 4, 6, 
		[ "Weight",    false,  9], 10, 
		[ "3D",        false, 12], 11, 
	]
	
	boundary   = new BoundingBox( 0, 0, 1, 1 );
	cached_pos = ds_map_create();
	
	curr_sca  = 0;
	curr_coor = 0;
	curr_eqa  = 0;
	curr_orig = 0;
	curr_ran  = 0;
	curr_iran = 0;
	curr_shf  = 0;
	curr_d3d  = 0;
	
	curr_usew = 0;
	curr_wgfn = 0;
	
	fn0 = 0;
	fn1 = 0;
	fn2 = 0;
	
	_a = new __vec2P();
	_param = { x:0, y:0, t:0, r:0, O:0 };
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var hv = inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
	}
	
	static getLineCount		= function() /*=>*/ {return 1};
	static getSegmentCount	= function() /*=>*/ {return 1};
	static getLength		= function() /*=>*/ {return length};
	static getAccuLength	= function() /*=>*/ {return [ length ]};
	static getBoundary		= function() /*=>*/ {return boundary};
	
	static getPointRatio = function(_rat, ind = 0, out = undefined) {
		if(out == undefined) out = curr_d3d? new __vec3P() : new __vec2P(); 
		else { out.x = 0; out.y = 0; out.z = 0; }
		
		_rat = curr_ran[0] + (_rat * (curr_ran[1] - curr_ran[0]));
		
		switch(curr_coor) {
			case 0 :
				switch(curr_eqa) {
					case 0 : 
						_param.x = _rat * curr_iran[0] + curr_shf[0];
						
						out.x = _rat * curr_iran[0] + curr_shf[0];
						out.y = fn0.eval(_param);
						
						if(curr_usew) {
							_param.x = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
						
					case 1 : 
						_param.y = _rat * curr_iran[1] + curr_shf[1];
						
						out.x = fn0.eval(_param);
						out.y = _rat * curr_iran[1] + curr_shf[1];
						
						if(curr_usew) {
							_param.y = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
						
					case 2 : 
						_param.t = _rat * curr_iran[0] + curr_shf[0];
						out.x = fn0.eval(_param);
						
						_param.t = _rat * curr_iran[1] + curr_shf[1];
						out.y = fn1.eval(_param);
						
						if(curr_d3d) {
							_param.t = _rat;
							out.z = fn2.eval(_param);
						}
						
						if(curr_usew) {
							_param.t = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
				}
				break;
				
			case 1 :
				var _ax = 0, _ay = 0;
				
				switch(curr_eqa) {
					case 0 : 
						_param.r = _rat * curr_iran[0] + curr_shf[0];
						
						_ax = _rat * curr_iran[0] + curr_shf[0];
						_ay = fn0.eval(_param);
						
						if(curr_usew) {
							_param.r = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
						
					case 1 : 
						_param.O = _rat * curr_iran[1] + curr_shf[1];
						
						_ax = fn0.eval(_param);
						_ay = _rat * curr_iran[1] + curr_shf[1];
						
						if(curr_usew) {
							_param.O = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
						
					case 2 : 
						_param.t = _rat * curr_iran[0] + curr_shf[0];
						_ax = fn0.eval(_param);
						
						_param.t = _rat * curr_iran[1] + curr_shf[1];
						_ay = fn1.eval(_param);
						
						if(curr_d3d) {
							_param.t = _rat;
							out.z = fn2.eval(_param);
						}
						
						if(curr_usew) {
							_param.t = _rat;
							out.weight = fnw.eval(_param);
						}
						break;
				}
				
				out.x =  cos(_ay) * _ax;
				out.y = -sin(_ay) * _ax;
				break;
		}
		
		out.x =  out.x * curr_sca[0] + curr_orig[0];
		out.y = -out.y * curr_sca[1] + curr_orig[1];
		
		return out;
	}
	
	static getPointDistance = function(_dist, ind = 0, out = undefined) { return getPointRatio(_dist / getLength(ind), ind, out); }
	
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
		curr_sca  = getInputData(0);
		curr_coor = getInputData(1);
		curr_eqa  = getInputData(2);
		curr_orig = getInputData(5);
		curr_ran  = getInputData(6);
		curr_iran = getInputData(7);
		curr_shf  = getInputData(8);
		curr_usew = getInputData(9);
		curr_wgfn = getInputData(10);
		curr_d3d  = getInputData(12);
		
		var _eq0  = getInputData(3);
		var _eq1  = getInputData(4);
		var _eq2  = getInputData(11);
		
		fn0 = evaluateFunctionList(_eq0);
		fn1 = evaluateFunctionList(_eq1);
		fn2 = evaluateFunctionList(_eq2);
		fnw = evaluateFunctionList(curr_wgfn);
		
		_a = curr_d3d? new __vec3P() : new __vec2P();
		
		updateBoundary();
		outputs[0].setValue(self);
		
		#region display
			inputs[ 2].editWidget.data_list = curr_coor? eq_type_pol : eq_type_car;
			inputs[ 4].setVisible(curr_eqa == 2);
			
			switch(curr_coor) {
				case 0 :
					switch(curr_eqa) {
						case 0 : 
							inputs[ 3].name = "f(x) = ";
							inputs[ 6].name = "x range";
							inputs[10].name = "w(x) = ";
							break;
							
						case 1 : 
							inputs[ 3].name = "f(y) = ";
							inputs[ 6].name = "y range";
							inputs[10].name = "w(y) = ";
							break;
							
						case 2 : 
							inputs[ 3].name = "x(t) = ";
							inputs[ 4].name = "y(t) = ";
							inputs[ 6].name = "t range";
							inputs[10].name = "w(t) = ";
							break;
					}
					break;
					
				case 1 :
					switch(_eqa) {
						case 0 : 
							inputs[ 3].name = "f(r) = ";
							inputs[ 6].name = "r range";
							inputs[10].name = "w(r) = ";
							break;
							
						case 1 : 
							inputs[ 3].name = "f(O) = ";
							inputs[ 6].name = "O range";
							inputs[10].name = "w(O) = ";
							break;
							
						case 2 : 
							inputs[ 3].name = "r(t) = ";
							inputs[ 4].name = "O(t) = ";
							inputs[ 6].name = "t range";
							inputs[10].name = "w(t) = ";
							break;
					}
					break;
			}
		#endregion
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_trim, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}