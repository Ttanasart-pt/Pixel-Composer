#region global
	globalvar RANDOMIZER_ACTIVE; RANDOMIZER_ACTIVE = false;

	function Project_Randomizer_Section(_name = "") constructor {
		name = _name;
		coll = false;
		indx = 0;
		
		y  = 0;
		y1 = 0;
		h  = 0;
		
		////- =Serialize
		
		static serialize = function() {
			var _m = {};
			
			_m.data = "section";
			
			_m.name = name;
			_m.coll = coll;
			return _m;
		}
		
		static deserialize = function(_m) {
			name = _m[$ "name"] ?? name;
			coll = _m[$ "coll"] ?? coll;
			return self;
		}
	}
	
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
			if(node_id == 0) node = PROJECT.globalNode;
			else             node = PROJECT.nodeMap[? node_id];
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
		
		////- =Serialize
		
		static serialize = function() {
			var _m = {};
			
			_m.data    = "random";
			
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
	
	function Randomizer_Track_Deserialize(_data) {
		var _type = _data[$ "data"] ?? "random";
		
		switch(_type) {
			case "random" :  return new Project_Randomizer_Value().deserialize(_data);
			case "section" : return new Project_Randomizer_Section().deserialize(_data);
		}
		
		return undefined;
	}
	
	function Project_Randomizer() constructor {
		seed   = seed_random(6);
		values = [];
		
		static addTrack = function(t) /*=>*/ { array_push(values, t); }
		
		static removeValue = function(v) /*=>*/ {
			for( var i = array_length(values) - 1; i >= 0; i-- ) {
				if(!is(values[i], Project_Randomizer_Value)) continue;
				if(values[i].value == v) array_delete(values, i, 1);
			}
		}
		
		static hasValue = function(v) /*=>*/ {
			for( var i = 0, n = array_length(values); i < n; i++ ) {
				if(!is(values[i], Project_Randomizer_Value)) continue;
				if(values[i].value == v) return true;
			}
			
			return false;
		}
		
		static Random = function() /*=>*/ {
			for( var i = 0, n = array_length(values); i < n; i++ ) {
				if(!is(values[i], Project_Randomizer_Value)) continue;
				values[i].Random();
			}
		}
		
		static serialize = function() {
			var _m = {};
			_m.values = array_map(values, function(t,i) /*=>*/ {return t.serialize()} );
			return _m;
		}
		
		static deserialize = function(_m) {
			values = array_create(array_length(_m.values));
			for( var i = 0, n = array_length(_m.values); i < n; i++ )
				values[i] = Randomizer_Track_Deserialize(_m.values[i]);
			return self;
		}
	}
#endregion

function Panel_Randomizer() : PanelContent() constructor {
	title = "Randomizer";
	w = ui(640);
	h = ui(320);
	
	auto_pin   = true;
	editing    = false;
	randActive = false;
	
	section_list = [];
	
	dragging       = false;
	dragging_track = undefined;
	
	section_editing = undefined;
	section_editor  = textBox_Text(function(txt) /*=>*/ {
		if(section_editing == undefined) return;
		section_editing.name = txt;
		section_editing = undefined;
	})
	
	sc_randomize = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww  = sc_randomize.surface_w;
		
		var _rnd  = PROJECT.randomizer;
		var _trks = _rnd.values;
		
		var group_labels = [];
		var currSec      = undefined;
		
		var sectColl = false;
		var sectH    = ui(20);
		var lbh      = sectH;
		
		var pd = ui(6);
		
		var hg = ui(24);
		var xx = 0;
		var x1 = ww - pd;
		var yy = _y + ui(8);
		
		var bs = sectH;
		var bc = [COLORS._main_icon, COLORS._main_icon_light];
		
		var rx = x + sc_randomize.x;
		var ry = y + sc_randomize.y;
		
		var eh = hg - ui(4);
		var _del = undefined;
	
		var hov = sc_randomize.hover && _m[1] > lbh;
		var foc = sc_randomize.active;
		
		var drag_hover_index = 0;
		
		#region section bg
			var len = array_length(section_list);
			for( var i = 0, n = array_length(section_list); i < n; i++ ) {
				var lb = section_list[i];
				var _name = lb.name;
				var _coll = lb.coll && !editing;
				
				var _lbh  = lb.y1 - lb.y;
				
				var scx = 0;
				var scy = lb.y;
				var scw = ww;
				var sch = sectH;
				
				if(!_coll) draw_sprite_stretched_add(THEME.box_r5, 0, scx, scy, scw, max(sch, _lbh), COLORS.panel_bg_clear, .2);
			}
		#endregion
    		
		for( var i = 0, n = array_length(_trks); i < n; i++ ) {
			var _trk = _trks[i];
			
			if(_m[1] > yy) drag_hover_index = i;
			
			if(is(_trk, Project_Randomizer_Section)) {
				if(currSec) { 
					var _coll = currSec.coll && !editing;
					if(!_coll) yy += ui(6);
					else       yy += ui(4);
					
				} else if(i)
					yy += ui(2);
				
				_trk.indx = i;
				_trk.y    = yy;
				_trk.y1   = yy;
				sectColl  = _trk.coll;
				currSec   = _trk;
				
				array_push(group_labels, currSec);
				
				yy += sectH;
				continue;
			}
		
			if(sectColl) continue;
			
			if(!is(_trk, Project_Randomizer_Value)) continue;
			
			var _nod = _trk.getNode();
			var _val = _trk.getValue();
			
			if(!is(_val, NodeValue)) continue;
			
			var _nnam = _nod.getDisplayName();
			var _vnam = _val.getName();
			
			var hgh = hg;
			var tx  = pd;
			var hv  = hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy+hg);
			
			if(editing) {
				var bx = tx;
				var by = yy + hg / 2 - bs / 2;
				var bc = COLORS._main_icon;
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.hamburger_s, 0, bc, 1, ui(6)) == 2) {
					dragging       = true;
					dragging_track = _trk;
				}
				
				tx += bs;
			}
			
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
				var bx = x1 - bs;
				var by = yy + hg / 2 - bs / 2;
				var bc = COLORS._main_value_negative;
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Delete"), THEME.cross_16, 0, bc, 1, ui(6)) == 2)
					_del = i;
				bx -= ui(4);
					
				if(currSec) currSec.y1 = max(currSec.y1, yy + hgh + ui(2));
				yy += hgh;
				continue;
			}
			
			var bx = x1 - bs;
			var by = yy + hg / 2 - bs / 2;
			if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Randomize"), THEME.icon_random, 0, bc) == 2)
				_trk.Random();
			bx -= ui(4);
			
			var _typeWidget = _trk.typeWidget;
			var _editWidget = _trk.getEditWidget();
			
			var edw = x1 * .4;
			
			if(_typeWidget) {
				var ew = x1 * .2;
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
			
			if(currSec) currSec.y1 = max(currSec.y1, yy + hgh + ui(2));
			yy += hgh;
		}
		
		if(_m[1] > yy) drag_hover_index = n-1;
		
		#region section label
			var len = array_length(group_labels);
			if(len && group_labels[0].y < lbh) {
				draw_set_color(COLORS.panel_bg_clear_inner);
				draw_rectangle(0, group_labels[0].y, ww, lbh, false);
			}
			
			var _cAll = 0;
			var scs = gpu_get_scissor();
			
			for( var i = 0; i < len; i++ ) {
				var lb = group_labels[i];
				var _name = lb.name;
				var _coll = lb.coll && !editing;
				
				var _yy   = max(lb.y, i == len - 1? ui(2) : min(ui(2), group_labels[i + 1].y - ui(32)));
				var _hv   = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + sectH);
				var _lbh  = lb.y1 - _yy;
				
				var scx = 0;
				var scy = _yy;
				var scw = ww;
				var sch = sectH;
				
				if(_coll) {
					draw_sprite_stretched_ext(THEME.section_separator, 0, scx, scy, scw, _coll? sch : _lbh, COLORS.section_bg);
				} else {
					gpu_set_scissor(scx, 0, scw, lbh+1);
					draw_sprite_stretched_add(THEME.box_r5, 0, scx, scy, scw, _lbh, COLORS.panel_bg_clear, .2);
					gpu_set_scissor(scs);
    				
            		var hovCnt = pHOVER && point_in_rectangle(_m[0], _m[1], scx, scy, scx + scw, scy + _lbh);
            		if(hovCnt) draw_sprite_stretched_add(THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover, .4);
				}
        		
            	if(!_coll) draw_sprite_stretched_ext( THEME.section_separator, 2, scx, scy, scw, sch, COLORS.section_selected  );
            	if(_hv) {
            		draw_sprite_stretched_ext( THEME.section_separator, 3, scx, scy, scw,  sch, COLORS.section_hover, .2 );
            		draw_sprite_stretched_ext( THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover     );
            	}
				
				if(!editing) {
					var bx = x1 - bs;
					var by = scy + sch / 2 - bs / 2;
					
					var bc = [COLORS._main_icon, COLORS._main_icon_light];
					var bt = __txt("Randomize Section");
					var bb = buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, bt, THEME.icon_random, 0, bc, 1, ui(6));
					if(bb) _hv = false;
					if(bb == 2) randomizeSection(lb.indx);
					bx -= ui(4);
					
					if(_hv && pFOCUS) {
	                	if(DOUBLE_CLICK) 
	                		_cAll = _coll? -1 : 1;
	                		
	                	else if(mouse_lpress()) 
	                    	lb.coll = !lb.coll;
					}
                }
	                
				if(editing) {
					var by = scy + sch / 2 - bs / 2;
					
					var bx = pd;
					var bc = COLORS._main_icon;
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.hamburger_s, 0, bc, 1, ui(6)) == 2) {
						dragging       = true;
						dragging_track = lb;
					} tx += bs;
					
					var bx = x1 - bs;
					var bc = COLORS._main_value_negative;
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Delete"), THEME.cross_16, 0, bc, 1, ui(6)) == 2)
						_del = lb.indx;
					bx -= ui(4);
					
					draw_set_text(f_p4, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
					var tx = pd + bs + ui(4);
					var ty = _yy + sectH / 2
					
					var tw = string_width(_name)  + ui(4);
					var th = string_height(_name) + ui(4);
					
					var tx0 = tx  - ui(2);
					var tx1 = tx0 + tw;
					var ty0 = ty  - th / 2;
					var ty1 = ty  + th / 2;
					
					if(section_editing == lb) {
						section_editor.setFocusHover(pFOCUS, pHOVER);
						section_editor.drawParam(new widgetParam(tx0, ty0, bx - tx0 - ui(8), th, _name, undefined, _m).setFont(f_p4));
						
					} else {
						draw_text_add(tx, ty, _name);
						
						if(pHOVER && point_in_rectangle(_m[0], _m[1], tx0, ty0, tx1, ty1)) {
							draw_sprite_stretched_ext(THEME.box_r2_clr, 1, tx0, ty0, tx1 - tx0, ty1 - ty0);
							if(mouse_lpress(pFOCUS)) {
								section_editing = lb;
								section_editor.activate(_name);
							}
						}
					}
					
				} else {
					draw_sprite_ui(THEME.arrow, _coll? 0 : 3, ui(16), _yy + sectH / 2, 1, 1, 0, COLORS._main_text_sub, 1);    
				
					draw_set_text(f_p4, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
					draw_text_add(ui(28), _yy + sectH / 2, _name);
				}
			}
			
				 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) group_labels[i].coll = false; } 
			else if(_cAll == -1) { for( var i = 0; i < len; i++ ) group_labels[i].coll =  true; }
			
			section_list = group_labels;
		#endregion
    		
		if(_del != undefined) array_delete(_trks, _del, 1);
		
		if(dragging) {
			array_remove(_trks, dragging_track);
			array_insert(_trks, drag_hover_index, dragging_track);
			
			if(mouse_lrelease()) dragging = false;
		}
		
		return yy - _y + ui(16);
	});
	
	function randomSeed() {
		var _nodes = PANEL_GRAPH.nodes_selecting;
		if(array_empty(_nodes)) return;
		
		randomize();
		array_foreach(_nodes, function(n,_) /*=>*/ {
			if(is(n.input_seed, NodeValue)) 
				n.input_seed.setValue(seed_random(6));
			return true;
		})
	}
	
	static randomizeSection = function(_index) {
		var _rnd  = PROJECT.randomizer;
		var _trks = _rnd.values;
		
		for( var i = _index+1, n = array_length(_trks); i < n; i++ ) {
			var _trk = _trks[i];
			if(is(_trk, Project_Randomizer_Section)) break;
			_trk.Random();
		}
	}
	
	static stepBegin = function() {
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
		var bc = COLORS._main_accent;
		
		var bt = __txt("Randomize All");
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.icon_random, 0, bc) == 2)
			_rnd.Random();
		bx += bs + ui(4);
		
		var bt = __txt("Randomize Selected nodes seed");
		var bc = COLORS._main_icon;
		var ac = !array_empty(PANEL_GRAPH.nodes_selecting);
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, ac && hov, foc, bt, THEME.icon_random_seed, 0, bc, .5 + ac*.5) == 2)
			randomSeed();
		bx += bs + ui(4);
		
		var n = PANEL_INSPECTOR.getInspecting();
		
		bx = w - ui(8) - bs;
		bc = n == noone? COLORS._main_icon_dark : [COLORS._main_icon, COLORS._main_value_positive];
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Add Value"), THEME.add_16, 0, bc) == 2) {
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
							array_push(menu, menuItem(_inp.getName(), function(v) /*=>*/ {return PROJECT.randomizer.addTrack(new Project_Randomizer_Value(v))})
								.setParam(_inp));
							break;
					}
					
				}
				
				if(array_last(menu) == -1) array_delete(menu, array_length(menu) - 1, 1);
				if(!array_empty(menu)) menuCall("", menu);
			}
		} bx -= bs + ui(4);
		
		bc = [COLORS._main_icon, COLORS._main_value_positive];
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Add Section"), THEME.tag, 0, bc, 1, ui(8)) == 2)
			PROJECT.randomizer.addTrack(new Project_Randomizer_Section("New Section"))
		bx -= bs + ui(4);
		
		bc = editing? COLORS._main_value_positive : COLORS._main_icon;
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Edit"), THEME.gear_16, 0, bc) == 2)
			editing = !editing;
		bx -= bs + ui(4);
		
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