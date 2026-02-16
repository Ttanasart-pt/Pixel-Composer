function Node_MK_Flag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Flag";
	update_on_frame = true;
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Flag
	newInput( 4, nodeValue_Int(         "Subdivision",  16   ));
	newInput( 1, nodeValue_Surface(     "Texture"            ));
	newInput( 2, nodeValue_Vec2(        "Position",    [0,0] )).setHotkey("G");
	newInput( 3, nodeValue_Enum_Button( "Pin side",     0    )).setChoices([ "Left", "Right", "Up", "Down" ]);
	
	////- =Wave
	newInput( 6, nodeValue_Slider( "Wave width",        1, [0, 4, 0.1]     ));
	newInput( 7, nodeValue_Slider( "Wave size",        .2                  ));
	newInput( 5, nodeValue_Int(    "Wind speed",        2                  ));
	newInput( 8, nodeValue_Slider( "Phase",            .1                  ));
	newInput( 9, nodeValue_Slider( "Clip",             .2                  ));
	
	////- =Rendering
	newInput(10, nodeValue_Slider( "Shadow",           .2                  ));
	newInput(11, nodeValue_Slider( "Shadow threshold",  0, [-.1, .1, .001] ));
	newInput(12, nodeValue_Bool(   "Invert shadow",     0                  ));
	// input 13
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		["Flag",	    false], 4, 1, 2, 3, 
		["Wave",	    false], 6, 7, 5, 8, 9, 
		["Rendering",	false], 10, 11, 12, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attributes.iteration = 4;
	array_push(attributeEditors, "Verlet solver");
	array_push(attributeEditors, Node_Attribute("Iteration", function() /*=>*/ {return attributes.iteration}, function() /*=>*/ {return textBox_Number(function(v) /*=>*/ {return setAttribute("iteration", v, true)})}));
	
	temp_surface = [ noone, noone ];
	
	////- Data
	
	function fPoints(_x, _y, _u, _v) constructor {
		x   = _x;
		y   = _y;
		sx  = _x;
		sy  = _y;
		u   = _u;
		v   = _v;
		pin = false;
	}
	
	function fLink(_p0, _p1) constructor {
		p0 = _p0;
		p1 = _p1;
		dist = point_distance(_p0.x, _p0.y, _p1.x, _p1.y);
	}
	
	function fMesh(_p0, _p1, _p2) constructor {
		p0 = _p0;
		p1 = _p1;
		p2 = _p2;
	}
	
	points = [];
	links  = [];
	meshes = [];
	
	////- Flag
	
	static onValueUpdate = function(index = 0) {
		if(index == 3 || index == 4) setGeometry();
	}
	
	static setGeometry = function() {
		var _pinn = getInputSingle(3);
		var _subd = getInputSingle(4); _subd = max(2, _subd);
		
		points = array_create((_subd + 1) * (_subd + 1));
		links  = array_create(2 * _subd * (_subd + 1));
		meshes = array_create(2 * _subd * _subd);
		
		var _ind = 0;
		for( var i = 0; i <= _subd; i++ ) 
		for( var j = 0; j <= _subd; j++ ) {
			points[_ind++] = new fPoints(i / _subd, j / _subd, i / _subd, j / _subd);
		}
		
		switch(_pinn) {
			case 0 : for( var i = 0; i <= _subd; i++ ) points[i].pin = true; break;
			case 1 : for( var i = 0; i <= _subd; i++ ) points[_subd * (_subd + 1) + i].pin = true; break;
			case 2 : for( var i = 0; i <= _subd; i++ ) points[i * (_subd + 1) + 0].pin     = true; break;
			case 3 : for( var i = 0; i <= _subd; i++ ) points[i * (_subd + 1) + _subd].pin = true; break;
		}
		
		var _ind = 0;
		for( var k = 0; k < 2; k++)
		for( var i = 0; i <  _subd; i++ ) 
		for( var j = 0; j <= _subd; j++ ) {
			var p0x = k? i : j;
			var p0y = k? j : i;
			var p1x = k? i + 1 : j;
			var p1y = k? j : i + 1;
			
			var i0 = p0y * (_subd + 1) + p0x;
			var i1 = p1y * (_subd + 1) + p1x;
			
			links[_ind++] = new fLink(points[i0], points[i1]);
		}
		
		var _ind = 0;
		for( var i = 0; i < _subd; i++ ) 
		for( var j = 0; j < _subd; j++ ) {
			var i0 = i * (_subd + 1) + j;
			var i1 = i * (_subd + 1) + j + 1;
			var i2 = (i + 1) * (_subd + 1) + j;
			
			meshes[_ind++] = new fMesh(points[i0], points[i1], points[i2]);
			
			var i0 = i * (_subd + 1) + j + 1;
			var i1 = (i + 1) * (_subd + 1) + j;
			var i2 = (i + 1) * (_subd + 1) + j + 1;
			
			meshes[_ind++] = new fMesh(points[i0], points[i1], points[i2]);
		}
	}
	
	static stepFlag = function() {
		var _pinn  = getInputSingle(3);
		var _wspd  = getInputSingle(5);
		var _wave  = getInputSingle(6);
		var _wavz  = getInputSingle(7);
		var _wphs  = getInputSingle(8);
		var _clip  = getInputSingle(9);
		
		var _tps = CURRENT_FRAME / TOTAL_FRAMES * _wspd * pi * 2;
		var _wve = _wave * pi;
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			var p = points[i];
			
			switch(_pinn) {
				case 0 : 
					var y0 = p.sy + max(-_clip, sin(p.u           * _wve - _tps)) * _wavz * p.u; 
					var y1 = p.sy + min( _clip, sin((p.u - _wphs) * _wve - _tps)) * _wavz * p.u;
					
					p.y = lerp(y0, y1, p.v);
					break;
				case 1 : 
					var y0 = p.sy + max(-_clip, sin((1 - p.u)           * _wve - _tps)) * _wavz * (1 - p.u); 
					var y1 = p.sy + min( _clip, sin(((1 - p.u) - _wphs) * _wve - _tps)) * _wavz * (1 - p.u);
					
					p.y = lerp(y0, y1, p.v);
					break;
				case 2 : 
					var x0 = p.sx + max(-_clip, sin(p.v           * _wve - _tps)) * _wavz * p.v; 
					var x1 = p.sx + min( _clip, sin((p.v - _wphs) * _wve - _tps)) * _wavz * p.v;
					
					p.x = lerp(x0, x1, p.u);
					break;
				case 3 : 
					var x0 = p.sx + max(-_clip, sin((1 - p.v)           * _wve - _tps)) * _wavz * (1 - p.v); 
					var x1 = p.sx + min( _clip, sin(((1 - p.v) - _wphs) * _wve - _tps)) * _wavz * (1 - p.v);
					
					p.x = lerp(x0, x1, p.u);
					break;
			}
		}
	}
	
	////- Render
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData_prebatch  = function() {
		if(IS_FIRST_FRAME) setGeometry();
		stepFlag();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim   = _data[0];
		var _tex   = _data[1];
		var _start = _data[2];
		var _pinn  = _data[3];
		
		var _shadow = _data[10];
		var _shdThr = _data[11];
		var _shdInv = _data[12];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		if(!is_surface(_tex)) return _outSurf;
		
		var _sx, _sy;
		var _sw = surface_get_width_safe(_tex);
		var _sh = surface_get_height_safe(_tex);
		
		switch(_pinn) {
			case 0 : _sx = _start[0];       _sy = _start[1];       break;
			case 1 : _sx = _start[0] - _sw; _sy = _start[1];       break;
			case 2 : _sx = _start[0];       _sy = _start[1];       break;
			case 3 : _sx = _start[0];       _sy = _start[1] - _sh; break;
		}
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_target_ext(0, temp_surface[0]);
		surface_set_target_ext(1, temp_surface[1]);
		shader_set(sh_mk_flag_mrt);
			DRAW_CLEAR
			draw_set_color(c_white);
			
			var _bat = 64;
			var _amo = array_length(meshes);
			
			for( var i = 0; i < _amo; i += _bat ) {
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_tex));
				for( var j = i; j < min(i + _bat, _amo); j++ ) {
					var m  = meshes[j];
					var p0 = m.p0;
					var p1 = m.p1;
					var p2 = m.p2;
					
					draw_vertex_texture(_sx + p0.x * _sw, _sy + p0.y * _sh, p0.u, p0.v);
					draw_vertex_texture(_sx + p1.x * _sw, _sy + p1.y * _sh, p1.u, p1.v);
					draw_vertex_texture(_sx + p2.x * _sw, _sy + p2.y * _sh, p2.u, p2.v);
				}
				draw_primitive_end();
			}
			
		shader_reset();
		surface_reset_target();
		
		surface_set_shader(_outSurf, sh_mk_flag_shade);
			shader_set_surface("textureMap", temp_surface[1]);
			shader_set_f("dimension",   _dim);
			shader_set_f("oriPosition", _start);
			shader_set_f("oriScale",    _sw, _sh);
			shader_set_f("shadow",      1-_shadow);
			shader_set_f("shadowThres", _shdThr);
			shader_set_i("shadowInv",   _shdInv);
			shader_set_i("side",        _pinn > 1);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}