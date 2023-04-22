function L_Turtle(x = 0, y = 0, ang = 90, w = 1, color = c_white) constructor {
	self.x   = x;
	self.y   = y;
	self.ang = ang;
	self.w   = w;
	self.color = color;
	
	static clone = function() {
		return new L_Turtle(x, y, ang, w, color);
	}
}

function Node_Path_L_System(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "L System";
	previewable = false;
	w = 96;
	
	inputs[| 0] = nodeValue("Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8);
	
	inputs[| 1] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 45)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 2] = nodeValue("Starting position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 4] = nodeValue("Starting rule", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_l_system);
	
	inputs[| 5] = nodeValue("End replacement", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", "Replace symbol of the last generated rule, for example a=F to replace all a with F. Use comma to separate different replacements.");
	
	inputs[| 6] = nodeValue("Starting angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 90)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	input_fix_len = ds_list_size(inputs);
	data_length = 2;
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Name " + string(index - input_fix_len), self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		inputs[| index + 1] = nodeValue("Rule " + string(index - input_fix_len), self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	rule_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		rule_renderer.x = _x;
		rule_renderer.y = _y;
		rule_renderer.w = _w;
		
		var hh = ui(8);
		var tx = _x + ui(32);
		var ty = _y + hh;
		
		var _tw = ui(64);
		var _th = TEXTBOX_HEIGHT + ui(4);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _name = inputs[| i + 0];
			var _rule = inputs[| i + 1];
			
			draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(_x + ui(8), ty + ui(8), string((i - input_fix_len) / data_length));
			
			_name.editWidget.setActiveFocus(_focus, _hover);
			_name.editWidget.draw(tx, ty, _tw, _th, _name.showValue(), _m, _name.display_type);
			
			draw_sprite_ui(THEME.arrow, 0, tx + _tw + ui(16), ty + _th / 2,,,, COLORS._main_icon);
			
			_rule.editWidget.setActiveFocus(_focus, _hover);
			_rule.editWidget.draw(tx + _tw + ui(32), ty, _w - (_tw + ui(8 + 24 + 32)), _th, _rule.showValue(), _m, _rule.display_type);
			
			ty += _th + ui(6);
			hh += _th + ui(6);
		}
		
		return hh;
	});
	
	input_display_list = [
		["Origin",		false], 2, 6, 
		["Properties",  false], 0, 1,
		["Rules",		false], 3, 4, rule_renderer, 5, 
	];
	lines = [];
	
	current_length  = 0;
	boundary = new BoundingBox();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			_l[| i] = inputs[| i];
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(inputs[| i].getValue() != "") {
				ds_list_add(_l, inputs[| i + 0]);
				ds_list_add(_l, inputs[| i + 1]);
			} else {
				delete inputs[| i + 0];	
				delete inputs[| i + 1];	
			}
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0; i < array_length(lines); i++ ) {
			var p0 = lines[i][0];
			var p1 = lines[i][1];
			
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
	}
	
	static getBoundary	= function() { return boundary; }
	
	static getLineCount		= function() { return array_length(lines); }
	static getSegmentCount	= function() { return 1; }
	static getLength		= function() { return current_length; }
	static getAccuLength	= function() { return [ 0, current_length ]; }
	
	static getWeightDistance = function (_dist, _ind = 0) { 
		return getWeightRatio(_dist / current_length, _ind); 
	}
	
	static getWeightRatio = function (_rat, _ind = 0) { 
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return 1;
		if(!is_array(_p1) || array_length(_p1) < 2) return 1;
		
		return lerp(_p0[2], _p1[2], _rat);
	}
	
	static getPointDistance = function(_dist, _ind = 0) {
		return getPointRatio(_dist / current_length, _ind); 
	}
	
	static getPointRatio = function(_rat, _ind = 0) {
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return new Point();
		if(!is_array(_p1) || array_length(_p1) < 2) return new Point();
		
		var _x  = lerp(_p0[0], _p1[0], _rat);
		var _y  = lerp(_p0[1], _p1[1], _rat);
		
		return new Point( _x, _y );
	}
	
	function update() { 
		var _len = inputs[| 0].getValue();
		var _ang = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		var _itr = inputs[| 3].getValue();
		var _san = inputs[| 6].getValue();
		lines = [];
		
		current_length = _len;
		
		if(ds_list_size(inputs) < input_fix_len + 2) return;
		
		var l  = inputs[| 4].getValue();
		
		var rules = ds_map_create();
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _name = inputs[| i + 0].getValue();
			var _rule = inputs[| i + 1].getValue();
			if(!ds_map_exists(rules, _name))
				rules[? _name] = [ _rule ];
			else
				array_push(rules[? _name], _rule);
		}
		
		for( var j = 1; j <= _itr; j++ ) {
			var s = "";
			for( var i = 1; i <= string_length(l); i++ ) {
				var ch = string_char_at(l, i);
				if(!ds_map_exists(rules, ch)) {
					s += ch;
					continue;
				}
				
				var _chr = rules[? ch];
				_chr = array_safe_get(_chr, irandom(array_length(_chr) - 1));
				
				s += _chr;
			}
			
			l = s;
			if(string_length(l) > 10000) break;
		}
		
		ds_map_destroy(rules);
		
		var _end = inputs[| 5].getValue();
		var _es  = string_splice(_end, ",");
		for( var i = 0; i < array_length(_es); i++ ) {
			var _sp = string_splice(_es[i], "=");
			if(array_length(_sp) == 2)
				l = string_replace_all(l, _sp[0], _sp[1]);
		}
		
		var st = ds_stack_create();
		var t = new L_Turtle(_pos[0], _pos[1], _san);
		
		for( var i = 1; i <= string_length(l); i++ ) {
			var ch = string_char_at(l, i);
			switch(ch) {
				case "F": 
					var nx = t.x + lengthdir_x(_len, t.ang);
					var ny = t.y + lengthdir_y(_len, t.ang);
					
					array_push(lines, [ [t.x, t.y, t.w], [nx, ny, t.w] ]);
					
					t.x = nx;
					t.y = ny;
					break;
				case "G": 
					t.x = t.x + lengthdir_x(_len, t.ang);
					t.y = t.y + lengthdir_y(_len, t.ang);
					break;
				case "f": 
					var nx = t.x + lengthdir_x(_len * frac(_itr), t.ang);
					var ny = t.y + lengthdir_y(_len * frac(_itr), t.ang);
					
					array_push(lines, [ [t.x, t.y, t.w], [nx, ny, t.w] ]);
					
					t.x = nx;
					t.y = ny;
					break;
				case "+": t.ang += _ang; break;
				case "-": t.ang -= _ang; break;
				case "|": t.ang += 180;  break;
				case "[": ds_stack_push(st, t.clone()); break;
				case "]": t = ds_stack_pop(st);			break;
				
				case ">": t.w += 0.1; break;
				case "<": t.w -= 0.1; break;
			}
		}
		
		ds_stack_destroy(st);
		
		boundary = new BoundingBox();
		for( var i = 0; i < array_length(lines); i++ )
			boundary.addPoint(lines[i][0][0], lines[i][0][1], lines[i][1][0], lines[i][1][1]);
		
		outputs[| 0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_l_system, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}