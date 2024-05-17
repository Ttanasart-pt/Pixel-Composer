function L_Turtle(x = 0, y = 0, ang = 90, w = 1, color = c_white) constructor { #region
	self.x   = x;
	self.y   = y;
	self.ang = ang;
	self.w   = w;
	self.color = color;
	
	static clone = function() { return new L_Turtle(x, y, ang, w, color); }
} #endregion

function Node_Path_L_System(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "L System";
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 8);
	
	inputs[| 1] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 2] = nodeValue("Starting position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 4] = nodeValue("Starting rule", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", o_dialog_l_system);
	
	inputs[| 5] = nodeValue("End replacement", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "", "Replace symbol of the last generated rule, for example a=F to replace all a with F. Use comma to separate different replacements.");
	
	inputs[| 6] = nodeValue("Starting angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 90)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 7] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 7].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	setIsDynamicInput(2);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Name " + string(index - input_fix_len), self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		inputs[| index + 1] = nodeValue("Rule " + string(index - input_fix_len), self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
	} #endregion
	if(!LOADING && !APPENDING) createNewInput();
	
	outputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.output, VALUE_TYPE.pathnode, self);
	
	rule_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
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
			
			_name.editWidget.setFocusHover(_focus, _hover);
			_name.editWidget.draw(tx, ty, _tw, _th, _name.showValue(), _m, _name.display_type);
			
			draw_sprite_ui(THEME.arrow, 0, tx + _tw + ui(16), ty + _th / 2,,,, COLORS._main_icon);
			
			_rule.editWidget.setFocusHover(_focus, _hover);
			_rule.editWidget.draw(tx + _tw + ui(32), ty, _w - (_tw + ui(8 + 24 + 32)), _th, _rule.showValue(), _m, _rule.display_type);
			
			ty += _th + ui(6);
			hh += _th + ui(6);
		}
		
		return hh;
	}, function(parent = noone) {
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _name = inputs[| i + 0];
			var _rule = inputs[| i + 1];
			
			_name.editWidget.register(parent);
			_rule.editWidget.register(parent);
		}
	}); #endregion
	
	input_display_list = [
		["Origin",		false], 2, 6, 
		["Properties",  false], 0, 1, 7, 
		["Rules",		false], 3, 4, rule_renderer, 5, 
	];
	lines = [];
	
	attributes.rule_length_limit = 10000;
	array_push(attributeEditors, "L System");
	array_push(attributeEditors, [ "Rule length limit", function() { return attributes.rule_length_limit; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.rule_length_limit = val; 
			cache_data.start = "";
			triggerRender();
		}) ]);
	
	current_length  = 0;
	boundary = new BoundingBox();
	
	cache_data = {
		start: "",
		rules: {},
		end_rule: "",
		iteration: 0,
		seed: 0,
		result: ""
	}
	
	static refreshDynamicInput = function() { #region
		var _l = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			_l[| i] = inputs[| i];
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(getInputData(i) != "") {
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
	} #endregion
	
	static onValueUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		draw_set_color(COLORS._main_accent);
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
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
	} #endregion
	
	static getLineCount		= function() { return array_length(lines); }
	static getSegmentCount	= function() { return 1; }
	
	static getLength		= function() { return current_length; }
	static getAccuLength	= function() { return [ 0, current_length ]; }
	
	static getWeightDistance = function (_dist, _ind = 0) { #region
		return getWeightRatio(_dist / current_length, _ind); 
	} #endregion
	
	static getWeightRatio = function (_rat, _ind = 0) { #region
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return 1;
		if(!is_array(_p1) || array_length(_p1) < 2) return 1;
		
		return lerp(_p0[2], _p1[2], _rat);
	} #endregion
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) { #region
		if(out == undefined) out = new __vec2(); else { out.x = 0; out.y = 0; }
		
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return out;
		if(!is_array(_p1) || array_length(_p1) < 2) return out;
		
		out.x  = lerp(_p0[0], _p1[0], _rat);
		out.y  = lerp(_p0[1], _p1[1], _rat);
		
		return out;
	} #endregion
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { return getPointRatio(_dist / current_length, _ind, out); }
	
	static getBoundary	= function() { return boundary; }
	
	static l_system = function(_start, _rules, _end_rule, _iteration, _seed) { #region
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
				noti_warning($"L System: Rules length limit ({attributes.rule_length_limit}) reached.");
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
	} #endregion
	
	static update = function() { #region
		var _len = getInputData(0);
		var _ang = getInputData(1);
		var _pos = getInputData(2);
		var _itr = getInputData(3);
		var _sta = getInputData(4);
		var _end = getInputData(5);
		var _san = getInputData(6);
		var _sad = getInputData(7);
		lineq = ds_queue_create();
		
		random_set_seed(_sad);
		current_length = _len;
		
		if(ds_list_size(inputs) < input_fix_len + 2) return;
		
		var rules = {};
		for( var i = input_fix_len; i < ds_list_size(inputs) - data_length; i += data_length ) {
			var _name = getInputData(i + 0);
			var _rule = getInputData(i + 1);
			if(!struct_has(rules, _name))
				rules[$ _name] = [ _rule ];
			else
				array_push(rules[$ _name], _rule);
		}
		
		l_system(_sta, rules, _end, _itr, _sad);
		itr = _itr;
		ang = _ang;
		len = _len;
		st  = ds_stack_create();
		t   = new L_Turtle(_pos[0], _pos[1], _san);
		
		string_foreach(cache_data.result, function(_ch, _) {
			switch(_ch) {
				case "F": 
					var nx = t.x + lengthdir_x(len, t.ang);
					var ny = t.y + lengthdir_y(len, t.ang);
					
					ds_queue_enqueue(lineq, [ [t.x, t.y, t.w], [nx, ny, t.w] ]);
					
					t.x = nx;
					t.y = ny;
					break;
				case "G": 
					t.x = t.x + lengthdir_x(len, t.ang);
					t.y = t.y + lengthdir_y(len, t.ang);
					break;
				case "f": 
					var nx = t.x + lengthdir_x(len * frac(itr), t.ang);
					var ny = t.y + lengthdir_y(len * frac(itr), t.ang);
					
					ds_queue_enqueue(lineq, [ [t.x, t.y, t.w], [nx, ny, t.w] ]);
					
					t.x = nx;
					t.y = ny;
					break;
				case "+": t.ang += ang; break;
				case "-": t.ang -= ang; break;
				case "|": t.ang += 180; break;
				case "[": ds_stack_push(st, t.clone()); break;
				case "]": t = ds_stack_pop(st);			break;
				
				case ">": t.w += 0.1; break;
				case "<": t.w -= 0.1; break;
			}
		});
		
		ds_stack_destroy(st);
		
		boundary = new BoundingBox();
		
		lines = array_create(ds_queue_size(lineq));
		var i = 0;
		
		while(!ds_queue_empty(lineq)) {
			var _l = ds_queue_dequeue(lineq);
			lines[i++] = _l;
			boundary.addPoint(_l[0][0], _l[0][1], _l[1][0], _l[1][1]);
		}
		
		ds_queue_destroy(lineq);
		
		outputs[| 0].setValue(self);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_path_l_system, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}