function L_Turtle(x = 0, y = 0, z = 0, ang = 90, w = 1, color = c_white, itr = 0) constructor {
	self.x     = x;
	self.y     = y;
	self.z     = z;
	self.ang   = ang;
	self.vang  = 0;
	self.w     = w;
	self.color = color;
	self.itr   = itr;
	
	static clone = function() { 
		var t = new L_Turtle(x, y, z, ang, w, color, itr); 
		t.vang = vang;
		return t;
	}
}

function Node_Path_L_System(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "L System";
	setDimension(96, 48);
	
	////- =Origin
	newInput( 2, nodeValue_Vec2(     "Starting position", [DEF_SURF_W/2,DEF_SURF_H/2] )).setHotkey("G");
	newInput(10, nodeValue_Vec3(     "Starting position", [0,0,0] ));
	newInput( 6, nodeValue_Rotation( "Starting Angle",     90     ));
	
	////- =Properties
	newInput(0, nodeValue_Float(     "Length",  8  ));
	newInput(1, nodeValue_Rotation(  "Angle",   45 ));
	newInput(7, nodeValueSeed());
		
	////- =3D
	newInput( 8, nodeValue_Bool(        "3D",       false ));
	newInput( 9, nodeValue_Enum_Button( "Forward",  1, [ "X", "Y", "Z" ] ));
	newInput(11, nodeValue_Rotation(    "Subangle", 45    ));
	
	////- =Rules
	newInput(3, nodeValue_Int(  "Iteration",    4 ));
	newInput(4, nodeValue_Text( "Starting rule"   ));
	newInput(5, nodeValue_Text( "End replacement" )).setTooltip("Replace symbol of the last generated rule, for example a=F to replace all a with F. Use comma to separate different replacements.");
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var _idx  = index - input_fix_len;
		
		newInput(index + 0, nodeValue_Text($"Name {_idx}"));
		newInput(index + 1, nodeValue_Text($"Rule {_idx}"));
		
		return inputs[index + 0];
	}
	
	rule_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus, _panel) /*=>*/ {
		rule_renderer.x = _x;
		rule_renderer.y = _y;
		rule_renderer.w = _w;
		
		var ff = f_p3;
		var hh = ui(4);
		var tx = _x + ui(32);
		var ty = _y + hh;
		
		var pv = ui(5);
		var tw = ui(64);
		var th = line_get_height(ff) + pv * 2;
		
		var rx = tx + tw + ui(24);
		var rw = _w - tw - ui(24 + 32) - th - ui(8);
		var wh, dh;
		
		var len = array_length(inputs);
		var amo = (len - input_fix_len) / data_length;
		var del = -1;
		
		for( var i = input_fix_len; i < len; i += data_length ) {
			var _name  = inputs[i + 0];
			var _rule  = inputs[i + 1];
			var _nameW = _name.editWidget;
			var _ruleW = _rule.editWidget;
			
			var _ind   = (i - input_fix_len) / data_length;
			var  wh    = th;
			var _last  = _ind == amo - 1;
			
			_nameW.setVAlign(pv);
			_ruleW.setVAlign(pv);
			
			var _par = new widgetParam(tx, ty, tw, th, _name.showValue(), {}, _m)
							.setFont(ff).setFocusHover(_focus, _hover);
			dh = _nameW.drawParam(_par);
			wh = max(wh, dh);
			
			draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(_x + ui(8), ty + dh / 2, _ind);
			draw_sprite_ui(THEME.arrow, 0, tx + tw + ui(12), ty + dh / 2, 1, 1, 0, COLORS._main_icon);
			
			var _nam = _name.showValue();
			var _par = new widgetParam(rx, ty, rw, th, _rule.showValue(), {}, _m)
							.setFont(ff).setFocusHover(_focus, _hover, _nam != "");
			dh = _ruleW.drawParam(_par);
			wh = max(wh, dh);
			
			var bs = th;
			var bx = _x + _w - bs;
			var by = ty;
			
			     if(_last) draw_sprite_ui_uniform(THEME.minus, 0, bx + bs / 2, by + bs / 2, 1, CDEF.main_dkblack);
			else if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, _focus, _hover, "", THEME.minus, 0, COLORS._main_value_negative) == 2)
				del = i;
			
			ty += wh + ui(6);
			hh += wh + ui(6);
		}
		
		if(del != -1) deleteRule(del);
		
		return hh;
		
	}, function(p = noone) /*=>*/ {
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			var _name = inputs[i + 0];
			var _rule = inputs[i + 1];
			var _nameW = _name.editWidget;
			var _ruleW = _rule.editWidget;
			
			_nameW.register(p);
			_ruleW.register(p);
		}
	});
	
	input_display_list = [
		["Origin",		false],    2, 10, 6, 
		["Properties",  false],    0, 1, 7, 
		["3D",          false, 8], 9, 11, 
		["Rules",		false],    3, 4, rule_renderer, 5, 
	];
	
	setDynamicInput(2, false);
	if(NOT_LOAD) createNewInput();
	
	attributes.rule_length_limit = 10000;
	array_push(attributeEditors, "L System" );
	array_push(attributeEditors, [ "Rule length limit", function() /*=>*/ {return attributes.rule_length_limit}, textBox_Number(function(v) /*=>*/ { setAttribute("rule_length_limit", v, true); cache_data.start = ""; }) ] );
	
	path_3d    = false;
	cache_data = {
		start     : "",
		rules     : {},
		end_rule  : "",
		iteration : 0,
		seed      : 0,
		result    : "",
	}
	
	static deleteRule = function(ind) {
		array_delete(inputs, ind, 2);
		array_foreach(inputs, function(inp, i) /*=>*/ {return inp.index = i});
	}
	
	static refreshDynamicInput = function() {
		var _l = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			_l[i] = inputs[i];
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i += data_length ) {
			if(getInputData(i) != "") {
				array_push(_l, inputs[i + 0]);
				array_push(_l, inputs[i + 1]);
			}
		}
		
		inputs = _l;
		array_foreach(inputs, function(inp, i) /*=>*/ {return inp.index = i});
		createNewInput();
	}
	
	static onValueUpdate = function(index) {
		if(index > input_fix_len && !LOADING && !APPENDING) 
			refreshDynamicInput();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		var _out = getSingleValue(0, preview_index, true);
		if(!is_struct(_out)) return w_hovering;
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(_out.lines); i < n; i++ ) {
			var p0 = _out.lines[i][0];
			var p1 = _out.lines[i][1];
			
			var x0 = p0[0];
			var y0 = p0[1];
			var x1 = p1[0];
			var y1 = p1[1];
			
			x0 = _x + x0 * _s;
			y0 = _y + y0 * _s;
			x1 = _x + x1 * _s;
			y1 = _y + y1 * _s;
				
			draw_line(x0, y0, x1, y1);
		}
		
		return w_hovering;
	}
	
	static drawOverlay3D = function(active, _mx, _my, _snx, _sny, _params) {
		
		var _out = getSingleValue(0, preview_index, true);
		if(!is_struct(_out)) return;
		
		var _qinv  = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1, 0, 0), 90);
		
		var _camera = _params.scene.camera;
		var _qview  = new BBMOD_Quaternion().FromEuler(_camera.focus_angle_y, -_camera.focus_angle_x, 0);
		var ray     = _camera.viewPointToWorldRay(_mx, _my);
		
		var _v3 = new __vec3();
		var _ox = 0, _oy = 0;
		var _nx = 0, _ny = 0;
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(_out.lines); i < n; i++ ) {
			var p0 = _out.lines[i][0];
			var p1 = _out.lines[i][1];
			
			_v3.x = p0[0];
			_v3.y = p0[1];
			_v3.z = p0[2];
			
			var _posView = _camera.worldPointToViewPoint(_v3);
			_nx = _posView.x;
			_ny = _posView.y;
			
			if(i) draw_line(_ox, _oy, _nx, _ny);
			
			_ox = _nx;
			_oy = _ny;
		}
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	function Path_LSystem() constructor {
		lines          = [];
		current_length = 0;
		boundary       = new BoundingBox();
		path_3d        = false;
		
		static getLineCount		= function() /*=>*/ {return array_length(lines)};
		static getSegmentCount	= function() /*=>*/ {return 1};
		static getLength		= function() /*=>*/ {return current_length};
		static getAccuLength	= function() /*=>*/ {return [ 0, current_length ]};
		
		static getPointRatio = function(_rat, _ind = 0, out = undefined) {
			if(out == undefined) out = path_3d? new __vec3() : new __vec2P(); 
			else { out.x = 0; out.y = 0; if(path_3d) out.z = 0; }
			
			var _p0 = lines[_ind][0];
			var _p1 = lines[_ind][1];
			
			if(!is_array(_p0) || array_length(_p0) < 2) return out;
			if(!is_array(_p1) || array_length(_p1) < 2) return out;
			
			out.x  = lerp(_p0[0], _p1[0], _rat);
			out.y  = lerp(_p0[1], _p1[1], _rat);
			
			if(path_3d) out.z  = lerp(_p0[2], _p1[2], _rat);
			
			return out;
		}
		
		static getPointDistance = function(_dist, _ind = 0, out = undefined) { return getPointRatio(_dist / current_length, _ind, out); }
		
		static getBoundary	= function() { return boundary; }
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static l_system = function(_start, _rules, _end_rule, _iteration, _seed) {
		if(isEqual(cache_data.rules, _rules, true)
			&& cache_data.start	     == _start
			&& cache_data.end_rule	 == _end_rule
			&& cache_data.iteration  == _iteration
			&& cache_data.seed	     == _seed) {
			
			return cache_data.result;
		}
		
		cache_data.start	 = _start;
		cache_data.rules	 = _rules;
		cache_data.end_rule	 = _end_rule;
		cache_data.iteration = _iteration;
		cache_data.seed		 = _seed;
		cache_data.result    = _start;
		
		_temp_s = "";
		
		for( var j = 1; j <= _iteration; j++ ) {
			_temp_s = "";
			
			string_foreach(cache_data.result, function(_ch, _) {
				if(!struct_has(cache_data.rules, _ch)) {
					_temp_s += _ch;
					return;
				}
				
				var _chr = cache_data.rules[$ _ch];
				_chr = array_safe_get_fast(_chr, irandom(array_length(_chr) - 1));
				
				_temp_s += _chr;
			})
			
			cache_data.result = _temp_s;
			if(string_length(cache_data.result) > attributes.rule_length_limit) {
				noti_warning($"L System: Rules length limit ({attributes.rule_length_limit}) reached.", noone, self);
				break;
			}
		}
		
		var _es  = string_splice(_end_rule, ",");
		for( var i = 0, n = array_length(_es); i < n; i++ ) {
			var _sp = string_splice(_es[i], "=");
			if(array_length(_sp) == 2)
				cache_data.result = string_replace_all(cache_data.result, _sp[0], _sp[1]);
		}
		
		return cache_data.result;
	}
	
	__curr_path = noone;
	static processData = function(_outSurf, _data, _array_index) {
		
		var _len  = _data[0];
		var _ang  = _data[1];
		var _itr  = _data[3];
		var _sta  = _data[4];
		var _end  = _data[5];
		var _san  = _data[6];
		var _sad  = _data[7];
		path_3d   = _data[8];
		var _for  = _data[9];
		var _pos  = path_3d? _data[10] : _data[2];
		var _vang = _data[11];
		
		inputs[ 2].setVisible(!path_3d);
		inputs[10].setVisible( path_3d);
		
		is_3D    = path_3d? NODE_3D.polygon : NODE_3D.none;
		lineq    = ds_queue_create();
		
		random_set_seed(_sad);
		__curr_path = new Path_LSystem();
		__curr_path.current_length = _len;
		__curr_path.path_3d        = path_3d;
		
		if(array_length(inputs) < input_fix_len + 2) return __curr_path;
		
		var _rules = {};
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _name = _data[i + 0];
			var _rule = _data[i + 1];
			if(_name == "") continue;
			
			if(!struct_has(_rules, _name))
				_rules[$ _name] = [ _rule ];
			else
				array_push(_rules[$ _name], _rule);
		}
		
		l_system(_sta, _rules, _end, _itr, _sad);
		itr    = _itr;
		ang    = _ang;
		vang   = _vang;
		len    = _len;
		forw   = _for;
		st     = ds_stack_create();
		t      = new L_Turtle(_pos[0], _pos[1], path_3d? _pos[2] : 0, _san);
		maxItr = 0;
		
		var nx, ny, nz;
		_llen = _len / 25;
		
		string_foreach(cache_data.result, function(_ch, _) {
			switch(_ch) {
				case "F": 
					if(path_3d) {
						nx = t.x + _llen * dcos(t.vang) * dcos(t.ang);
						ny = t.y + _llen * dcos(t.vang) * dsin(t.ang);
						nz = t.z + _llen * dsin(t.vang);
						
						switch(forw) {
							case 0 : ds_queue_enqueue(lineq, [ [ t.y, t.x, t.z, t.w, t.itr ], [ ny, nx, nz, t.w, t.itr + 1 ] ]); break;
							case 1 : ds_queue_enqueue(lineq, [ [ t.x, t.y, t.z, t.w, t.itr ], [ nx, ny, nz, t.w, t.itr + 1 ] ]); break;
							case 2 : ds_queue_enqueue(lineq, [ [ t.x, t.z, t.y, t.w, t.itr ], [ nx, nz, ny, t.w, t.itr + 1 ] ]); break;
						}
						
					} else {
						nx = t.x + lengthdir_x(len, t.ang);
						ny = t.y + lengthdir_y(len, t.ang);
						nz = t.z;
						ds_queue_enqueue(lineq, [ [ t.x, t.y, t.z, t.w, t.itr ], [ nx, ny, nz, t.w, t.itr + 1 ] ]);
						
					}
					
					t.x = nx;
					t.y = ny;
					t.z = nz;
					t.itr++;
					maxItr = max(maxItr, t.itr);
					
					break;
					
				case "G": 
					if(path_3d) {
						nx = t.x + _llen * dcos(t.vang) * dcos(t.ang);
						ny = t.y + _llen * dcos(t.vang) * dsin(t.ang);
						nz = t.z + _llen * dsin(t.vang);
						
					} else {
						nx = t.x + lengthdir_x(len, t.ang);
						ny = t.y + lengthdir_y(len, t.ang);
						nz = t.z;
					}
					
					t.x = nx;
					t.y = ny;
					break;
					
				case "f": 
					var _ll = _llen * frac(itr);
					
					if(path_3d) {
						nx = t.x + _ll * dcos(t.vang) * dcos(t.ang);
						ny = t.y + _ll * dcos(t.vang) * dsin(t.ang);
						nz = t.z + _ll * dsin(t.vang);
						
						switch(forw) {
							case 0 : ds_queue_enqueue(lineq, [ [ t.y, t.x, t.z, t.w, t.itr ], [ ny, nx, nz, t.w, t.itr + 1 ] ]); break;
							case 1 : ds_queue_enqueue(lineq, [ [ t.x, t.y, t.z, t.w, t.itr ], [ nx, ny, nz, t.w, t.itr + 1 ] ]); break;
							case 2 : ds_queue_enqueue(lineq, [ [ t.x, t.z, t.y, t.w, t.itr ], [ nx, nz, ny, t.w, t.itr + 1 ] ]); break;
						}
						
					} else {
						nx = t.x + lengthdir_x(_ll, t.ang);
						ny = t.y + lengthdir_y(_ll, t.ang);
						nz = t.z;
						ds_queue_enqueue(lineq, [ [ t.x, t.y, t.z, t.w, t.itr ], [ nx, ny, nz, t.w, t.itr + 1 ] ]);
						
					}
					
					t.x = nx;
					t.y = ny;
					t.z = nz;
					t.itr++;
					maxItr = max(maxItr, t.itr);
					break;
					
				case "+": t.ang  += ang; break;
				case "-": t.ang  -= ang; break;
				case "|": t.ang  += 180; break;
				
				case "*": t.vang += vang; break;
				case "/": t.vang -= vang; break;
				
				case "[": ds_stack_push(st, t.clone()); break;
				case "]": 
					if(ds_stack_empty(st)) noti_warning("L-system: Trying to pop an empty stack. Make sure that all close brackets ']' has a corresponding open bracket '['.", noone, self);
				    else t = ds_stack_pop(st);
				    break;
				
				case ">": t.w += 0.1; break;
				case "<": t.w -= 0.1; break;
				
			}
		});
		
		ds_stack_destroy(st);
		
		__curr_path.boundary = new BoundingBox();
		__curr_path.lines    = array_create(ds_queue_size(lineq));
		
		var i = 0;
		var a = ds_queue_size(lineq);
		
		repeat(a) {
			var _l = ds_queue_dequeue(lineq);
			
			__curr_path.lines[i++] = _l;
			__curr_path.boundary.addPoint(_l[0][0], _l[0][1], _l[1][0], _l[1][1]);
		}
		
		ds_queue_destroy(lineq);
		
		return __curr_path;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_path_l_system, 0, bbox, c_white, 1, true);
	}
	
	static getPreviewObject 		= function() /*=>*/ {return noone};
	static getPreviewObjects		= function() /*=>*/ {return []};
	static getPreviewObjectOutline  = function() /*=>*/ {return []};
	
}