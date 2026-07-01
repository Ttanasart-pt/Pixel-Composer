#region global
	globalvar RANDOMIZER_ACTIVE; RANDOMIZER_ACTIVE = false;
#endregion

function Project_Randomizer_Value(_val = undefined) constructor {
	value   = undefined;
	node    = undefined;
	node_id = "";
	inindex = 0;
	
	type       = 0;
	typeWidget = undefined;
	
	gradient = gra_black_white;
	palette  = array_clone(DEF_PALETTE);
	min_val  = 0;
	max_val  = 0;
	
	editWidgetGradient  = undefined;
	editWidgetPalette   = undefined;
	editWmin   = undefined;
	editWmax   = undefined;
	
	static getNode = function() /*=>*/ {
		if(node != undefined) return node;
		node = PROJECT.nodeMap[? node_id];
		return node;
	}
	
	static getValue = function() /*=>*/ {
		if(value != undefined) return value;
		
		var _node = getNode();
		if(_node == undefined) return undefined;
		
		value = array_safe_get_fast(_node.inputs, inindex);
		if(!is(value, NodeValue)) value = undefined;
		
		if(value == undefined) return value;
		
		var _wdg = value.getEditWidget();
		
		switch(value.type) {
			case VALUE_TYPE.color : 
				typeWidget = new scrollBox([ "Gradient", "Palette" ], function(i) /*=>*/ { type = i; });
				editWidgetGradient  = new buttonGradient(function(g) /*=>*/ { gradient = g; });
				editWidgetPalette   = new buttonPalette( function(p) /*=>*/ { palette  = p; });
				break;
				
			default :
				typeWidget = undefined;
				if(!is_array(min_val)) {
					editWmin = _wdg.clone();
					editWmax = _wdg.clone();
					
					editWmin.onModify = function(v) /*=>*/ { min_val = v; };
					editWmax.onModify = function(v) /*=>*/ { max_val = v; };
					
				} else {
					editWmin = _wdg.clone();
					editWmax = _wdg.clone();
					
					editWmin.onModify = function(v,i) /*=>*/ { min_val[i] = v; };
					editWmax.onModify = function(v,i) /*=>*/ { max_val[i] = v; };
				}
				break;
		}
		
		return value;
	}
	
	static getDisplayVal = function() /*=>*/ {
		if(value == undefined) return 0;
	
		switch(value.type) {
			case VALUE_TYPE.color : 
				     if(type == 0) return gradient;
				else if(type == 1) return palette;
		}
		
		return 0;
	}
	
	static getEditWidget = function() /*=>*/ {
		if(value == undefined) return undefined;
	
		switch(value.type) {
			case VALUE_TYPE.color : 
				     if(type == 0) return editWidgetGradient;
				else if(type == 1) return editWidgetPalette;
				
			default : return [ editWmax, editWmin ];
		}
		
		return undefined;
	} 
	
	static setInput = function(inp) /*=>*/ {
		node_id = inp.node.node_id;
	    inindex = inp.index;
	    
	    min_val = inp.getValue();
	    max_val = inp.getValue();
		
		getValue();
		return self;
		
	} if(_val) setInput(_val);
	
	static Random = function() /*=>*/ {
		randomize();
		
		var _v = getValue();
		if(!is(_v, NodeValue)) return;
		
		var _val = undefined;
		
		switch(_v.type) {
			case VALUE_TYPE.color : 
				if(type == 0 && is(gradient, gradientObject)) // gradient
					_val = gradient.eval(random(1));
					
				else if(type == 1 && !array_empty(palette)) // palette
					_val = array_safe_get(palette, irandom(array_length(palette) - 1));
				
				break;
				
			default : 
				if(is_numeric(min_val)) {
					if(_v.type == VALUE_TYPE.integer)
						 _val = irandom_range(min_val, max_val);
					else _val =  random_range(min_val, max_val);
					
				} else if(is_array(min_val)) {
					_val = array_create(array_length(min_val));
					
					for( var i = 0, n = array_length(min_val); i < n; i++ )
						_val[i] = random_range(min_val[i], max_val[i]);
				}		
		}
		
		if(_val != undefined) _v.setValue(_val);
	}
	
	static serialize = function() {
		var _m = {};
		
		_m.node_id = node_id;
		_m.inindex = inindex;
		
		_m.type    = type;
		
		_m.palt    = palette;
		_m.grad    = gradient? gradient.serialize() : 0;
		
		_m.min_val = min_val;
		_m.max_val = max_val;
		
		return _m;
	}
	
	static deserialize = function(_m) {
		node_id = _m[$ "node_id"] ?? node_id;
		inindex = _m[$ "inindex"] ?? inindex;
		
		type     = _m[$ "type"]   ?? type;
		
		palette  = _m[$ "palt"]   ?? palette;
		gradient = _m[$ "grad"]   ?? gradient;
		if(gradient != 0) gradient = new gradientObject().deserialize(gradient);
		
		min_val = _m[$ "min_val"] ?? min_val;
		max_val = _m[$ "max_val"] ?? max_val;
		
		return self;
	}
}

function Project_Randomizer() constructor {
	seed   = seed_random(6);
	values = [];
	
	static addTrack = function(t) /*=>*/ {return array_push(values, t)};
	
	static removeValue = function(v) /*=>*/ {
		for( var i = array_length(values) - 1; i >= 0; i-- )
			if(values[i].value == v) array_delete(values, i, 1);
	}
	
	static hasValue = function(v) /*=>*/ {
		for( var i = 0, n = array_length(values); i < n; i++ )
			if(values[i].value == v) return true;
		return false;
	}
	
	static Random = function() /*=>*/ {
		for( var i = 0, n = array_length(values); i < n; i++ )
			values[i].Random();
	}
	
	static serialize = function() {
		var _m = {};
		_m.values = array_map(values, function(t,i) /*=>*/ {return t.serialize()} );
		return _m;
	}
	
	static deserialize = function(_m) {
		values = array_create(array_length(_m.values));
		for( var i = 0, n = array_length(_m.values); i < n; i++ )
			values[i] = new Project_Randomizer_Value().deserialize(_m.values[i]);
		return self;
	}
}

function Panel_Randomizer() : PanelContent() constructor {
	title = "Randomizer";
	w = ui(640);
	h = ui(320);
	
	auto_pin   = true;
	editing    = false;
	randActive = false;
	
	sc_randomize = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var hov = sc_randomize.hover;
		var foc = sc_randomize.active;
		var ww  = sc_randomize.surface_w;
		var hh  = 0;
		
		var _rnd  = PROJECT.randomizer;
		var _trks = _rnd.values;
		
		var hg = ui(24);
		var xx = 0;
		var yy = _y;
		
		var bs = hg - ui(4);
		var bc = [COLORS._main_icon, COLORS._main_icon_light];
		
		var rx = x + sc_randomize.x;
		var ry = y + sc_randomize.y;
		
		var eh = hg - ui(4);
		var _del = undefined;
		
		for( var i = 0, n = array_length(_trks); i < n; i++ ) {
			var _trk = _trks[i];
			var _nod = _trk.getNode();
			var _val = _trk.getValue();
			if(!is(_val, NodeValue)) continue;
			
			var _nnam = _nod.getDisplayName();
			var _vnam = _val.getName();
			
			var hgh = hg;
			var tx  = 0;
			var hv  = hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy+hg);
			
			var spr = _nod.getMetaSpr();
			if(spr) {
				draw_sprite_ui(spr, 0, tx + ui(16), yy + hg / 2, .3, .3);
				tx += ui(32);
			}
			
			draw_set_text(f_p4, fa_left, fa_center);
			draw_set_color(COLORS._main_text_sub);
			draw_text_add(tx, yy + hg / 2, _nnam);
			tx += string_width(_nnam) + ui(4)
			
			draw_set_color(COLORS._main_text);
			draw_text_add(tx, yy + hg / 2, _vnam);
			
			if(editing) {
				var bx = ww - bs;
				var by = yy + hg / 2 - bs / 2;
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Delete"), THEME.cross, 0, COLORS._main_value_negative) == 2) {
					_del = i;
				} bx -= ui(4);
				
				yy += hgh + ui(0);
				hh += hgh + ui(0);
				continue;
			}
			
			var bx = ww - bs;
			var by = yy + hg / 2 - bs / 2;
			if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Randomize"), THEME.icon_random, 0, bc) == 2) {
				_trk.Random();
			} bx -= ui(4);
			
			var _typeWidget = _trk.typeWidget;
			var _editWidget = _trk.getEditWidget();
			
			var edw = ww * .4;
			
			if(_typeWidget) {
				var ew = ww * .2;
				var ex = bx - edw - ui(4) - ew;
				var ey = yy + hg / 2 - eh / 2;
				
				var dp = new widgetParam(ex, ey, ew, eh, _trk.type, undefined, _m, rx, ry).setFont(f_p4);
				
				_typeWidget.register(sc_randomize);
				_typeWidget.setFocusHover(foc, hov);
				var wh = _typeWidget.drawParam(dp);
				hgh = max(hg, wh);
				
			}
			
			if(is(_editWidget, widget)) {
				var ew = edw;
				var ex = bx - ew;
				var ey = yy + hg / 2 - eh / 2;
				
				var _edt = _editWidget;
				if(is(_edt, widget)) {
					var dp = new widgetParam(ex, ey, ew, eh, _trk.getDisplayVal(), undefined, _m, rx, ry).setFont(f_p3);
					
					_edt.register(sc_randomize);
					_edt.setFocusHover(foc, hov);
					var wh = _edt.drawParam(dp);
					hgh = max(hg, wh);
				}
				
				
			} else if(is_array(_editWidget)) {
				var ew = edw / 2;
				var ex = bx - ew;
				var ey = yy + hg / 2 - eh / 2;
				
				var _edt = _editWidget[0];
				if(is(_edt, widget)) {
					var dp = new widgetParam(ex, ey, ew, eh, _trk.max_val, undefined, _m, rx, ry).setFont(f_p3);
					
					_edt.register(sc_randomize);
					_edt.setFocusHover(foc, hov);
					var wh = _edt.drawParam(dp);
					hgh = max(hg, wh);
				}
				
				ex -= ew + ui(4);
				var _edt = _editWidget[1];
				if(is(_edt, widget)) {
					var dp = new widgetParam(ex, ey, ew, eh, _trk.min_val, undefined, _m, rx, ry).setFont(f_p3);
					
					_edt.register(sc_randomize);
					_edt.setFocusHover(foc, hov);
					var wh = _edt.drawParam(dp);
					hgh = max(hg, wh);
				}
			}
			
			yy += hgh + ui(0);
			hh += hgh + ui(0);
		}
		
		if(_del != undefined) array_delete(_trks, _del, 1);
		
		return hh;
	});
	
	function addValueTrack(v) { PROJECT.randomizer.addTrack(new Project_Randomizer_Value(v)); }
	
	static stepBegin   = function() {
		RANDOMIZER_ACTIVE = randActive;
		randActive = false;
	}
	
	function drawContent(panel) {
		randActive = true;
		
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var _rnd = PROJECT.randomizer;
		
		var bs  = ui(24);
		var m   = [mx,my];
		var hov = pHOVER;
		var foc = pFOCUS;
		
		var bb = THEME.button_hide;
		var bx = ui(8);
		var by = ui(8);
		var bc;
		
		var bt = __txt("Randomize All");
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.icon_random, 0, COLORS._main_accent) == 2)
			_rnd.Random();
		bx += bs + ui(4);
		
		var n = PANEL_INSPECTOR.getInspecting();
		
		bx = w - ui(8) - bs;
		bc = n == noone? COLORS._main_icon : COLORS._main_value_positive;
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Add Value"), THEME.add, 0, bc) == 2) {
			if(n != noone) {
				var dsp = is_array(n.input_display_list);
				var amo = dsp? array_length(n.input_display_list) : array_length(n.inputs);
				var menu = [];
				var _inp, _ind;
				
				for( var i = 0; i < amo; i++ ) {
					if(!dsp) {
						_ind = i;
						_inp = n.inputs[i];
						
					} else {
						_ind = n.input_display_list[i];
						if(!is_numeric(_ind)) {
							if(!array_empty(menu) && array_last(menu) != -1) array_push(menu, -1);
							continue
						}
						_inp = n.inputs[_ind];
					}
					
					if(!is(_inp, NodeValue) || (!_inp.show_in_inspector)) continue;
					
					switch(_inp.type) {
						case VALUE_TYPE.float : 
						case VALUE_TYPE.integer : 
						
						case VALUE_TYPE.color : 
							var _menu = new MenuItem(_inp.getName(), function(v) /*=>*/ { addValueTrack(v); }).setParam(_inp);
							array_push(menu, _menu);
							break;
					}
					
				}
				
				if(array_last(menu) == -1) array_delete(menu, array_length(menu) - 1, 1);
				if(!array_empty(menu)) menuCall("", menu);
			}
		} bx -= bs + ui(4);
		
		bc = editing? COLORS._main_value_positive : COLORS._main_icon;
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Edit"), THEME.gear_16, 0, bc) == 2) {
			editing = !editing;
		} bx -= bs + ui(4);
		
		var px = ui(6);
		var py = ui(8) + bs + ui(4);
		var pw = w - (ui(6 + 6));
		var ph = h - (ui(8) + bs + ui(4 + 6));
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px, py, pw, ph);
		
		sc_randomize.verify(pw - ui(6), ph - ui(6));
		sc_randomize.setFocusHover(pFOCUS, pHOVER);
		sc_randomize.drawOffset(px + ui(3), py + ui(3), mx, my);
		
	}
}