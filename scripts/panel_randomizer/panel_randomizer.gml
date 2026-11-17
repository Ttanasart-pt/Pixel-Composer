#region global
	globalvar  RANDOMIZER_ACTIVE;  RANDOMIZER_ACTIVE = undefined;
	globalvar  RANDOMIZER_HOVER;  RANDOMIZER_HOVER  = {};
	globalvar _RANDOMIZER_HOVER; _RANDOMIZER_HOVER  = {};
	
	globalvar  RANDOMIZER_VARIANT_ITERATE_RESET;  RANDOMIZER_VARIANT_ITERATE_RESET = false;
	
	function cartesian_product(ranges) {
	    var result = [[]];
	    
	    for (var i = 0; i < array_length(ranges); i++) {
	        var new_result = [];
	        
	        for (var j = 0; j < array_length(result); j++) {
	            for (var v = 0; v < ranges[i]; v++)
	                array_push(new_result, array_concat(result[j], [v]));
	        }
	        result = new_result;
	    }
	    
	    return result;
	}
	
	function Project_Randomizer_Track() constructor {
		name = "";
		bindNode = undefined;
		
		varients = [];
		varUse   = false;
		varIndex = -1;
		
		varRand    = false;
		varAmo     = 4;
		varAmoEdit = undefined;
		
		////- =Random
		
		static getVarEdit = function() {
			if(varAmoEdit) return varAmoEdit;
			varAmoEdit = textBox_Number(function(i) /*=>*/ { 
				varAmo = i; 
				generateVarients(); 
				return false; 
			}).setTooltip(__txt("Variant Amount"));
			
			return varAmoEdit;
		}
		
		static generateVarients = function( ) /*=>*/ {}
		static setVarients      = function(i) /*=>*/ { varIndex = i; }
		
		////- =Serialize
		
		static deserialize = function(_data) {
			var _type = _data[$ "data"] ?? "random";
			
			switch(_type) {
				case "random" :  return new Project_Randomizer_Value().deserialize(_data);
				case "section" : return new Project_Randomizer_Section().deserialize(_data);
			}
			
			return undefined;	
		}
		
		static toString = function() /*=>*/ {return $"Randomizer: {name}"};
	}
	
	function Project_Randomizer_Section(_name = "") : Project_Randomizer_Track() constructor {
		name = _name;
		coll = false;
		indx = 0;
		
		contents = [];
		
		y  = 0;
		y1 = 0;
		h  = 0;
		
		varHigh = undefined;
		
		////- =Random
		
		static generateVarients = function() {
			varients = [];
			
			var _rngs = [];
			
			for( var i = 0, n = array_length(contents); i < n; i++ ) {
				var _trk = contents[i];
				var _nod = _trk.getNode();
				if(!_nod.active) continue;
				
				var vamo = _trk.varUse? array_length(_trk.varients) : 1;
				array_push(_rngs, vamo)
			}
			
			if(array_empty(_rngs)) return;
			varients = cartesian_product(_rngs);
		}
		
		static setVarients = function(_i) { 
			varIndex = _i; 
			
    		var _ind = array_safe_get(varients, _i, []);
    		var _amo = min(array_length(contents), array_length(_ind));
    		
    		for( var i = 0; i < _amo; i++ ) {
    			var _trk = contents[i];
    			var _nod = _trk.getNode();
				if(!_nod.active) continue;
				
    			var _in  = _ind[i];
    			_trk.setVarients(_in);
    		}
    		
    		if(bindNode) bindNode.triggerRender();
		}
		
		////- =Serialize
		
		static serialize = function() {
			var _m = {};
			
			_m.data = "section";
			
			_m.varients = array_clone(varients);
			_m.varIndex = varIndex;
			_m.varUse   = varUse;
			_m.varRand  = varRand;
			_m.varAmo   = varAmo;
			
			_m.name = name;
			_m.coll = coll;
			
			return _m;
		}
		
		static deserialize = function(_m) {
			varients = array_clone(_m[$ "varients"] ?? varients);
			varIndex = _m[$ "varIndex"] ?? varIndex;
			varUse   = _m[$ "varUse"]   ?? varUse;
			varRand  = _m[$ "varRand"]  ?? varRand;
			varAmo   = _m[$ "varAmo"]   ?? varAmo;
			
			name = _m[$ "name"] ?? name;
			coll = _m[$ "coll"] ?? coll;
			return self;
		}
	}
	
	function Project_Randomizer_Value(_val = undefined) : Project_Randomizer_Track() constructor {
		value   = undefined;
		node    = undefined;
		node_id = "";
		inindex = 0;
		
		h = 0;
		
		type       = 0;
		typeWidget = undefined;
		varHigh    = undefined;
		
		gradient  = gra_black_white;
		palette   = array_clone(DEF_PALETTE);
		min_val   = 0;
		max_val   = 0;
		round_val = false;
		
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
					
					editWmin.unit = noone;
					editWmax.unit = noone;
					
					editWmin.side_button   = noone;
					editWmin.side_button2  = noone;
					editWmin.front_button  = noone;
					editWmin.front_button2 = noone;
					
					editWmax.side_button   = noone;
					editWmax.side_button2  = noone;
					editWmax.front_button  = noone;
					editWmax.front_button2 = noone;
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
			name = "";
			
			node_id = inp.node.node_id;
		    inindex = inp.index;
		    
		    var baseVal = inp.getValue();
		    min_val = baseVal;
		    max_val = baseVal;
			varAmo  = 4;
			
			var n = getNode();
			var v = getValue();
			
			if(!is(v, NodeValue)) return self;
			
			name = v.getName();
			
			var rangeMin = baseVal;
			var rangeMax = baseVal;
			round_val = v.type == VALUE_TYPE.integer;
			
			switch(v.type) {
				case VALUE_TYPE.float   : 
				case VALUE_TYPE.integer : 
					if(v.display_type == VALUE_DISPLAY.enum_button || v.display_type == VALUE_DISPLAY.enum_scroll) {
						var _chs = v.getChoices();
						rangeMin = 0;
						rangeMax = max(0, array_length(_chs) - 1);
					
					} else if(v.display_type == VALUE_DISPLAY.rotation) {
						rangeMin = 0;
						rangeMax = 360;
							
					} else {
						var wdgt = v.getEditWidget();
						
						if(is(wdgt, textBox) && wdgt.slide_range != noone) {
							rangeMin = wdgt.curr_range[0];
							rangeMax = wdgt.curr_range[1];
							
						} else if(is_real(baseVal)) {
							var dig = floor(logn(10, abs(baseVal)));
							rangeMin = power(10, dig);
							rangeMax = max(1, power(10, dig+1) - 1);
							
						} else if(is_array(baseVal)) {
							var vamo = array_length(baseVal);
							rangeMin = array_create(vamo);
							rangeMax = array_create(vamo);
							
							for( var i = 0; i < vamo; i++ ) {
								var dig = floor(logn(10, abs(baseVal[i])));
								rangeMin[i] = power(10, dig);
								rangeMax[i] = max(1, power(10, dig+1) - 1);
							}
						}
					}
					break;
					
				case VALUE_TYPE.text : 
					if(v.display_type == VALUE_DISPLAY.enum_string) {
						var _chs  = v.getChoices();
						rangeMin  = 0;
						rangeMax  = max(0, array_length(_chs) - 1);
						round_val = true;
					}
					break;
					
				case VALUE_TYPE.boolean : 
					rangeMin = 0;
					rangeMax = 1;
					varAmo   = 2;
					break;
			}
			
			min_val = rangeMin;
		    max_val = rangeMax;
		    
			return self;
			
		} if(_val) setInput(_val);
		
		////- =Random
		
		static generateVarients = function() {
			varients = array_verify(varients, varAmo);
			varIndex = -1;
			
			var v = getValue();
			if(!is(v, NodeValue)) return 0;
			
			for( var i = 0; i < varAmo; i++ ) {
				var _val = undefined;
				if(varRand) {
					varients[i] = Random();
					continue;
				}
					
				var _val = undefined;
				var _rat = i / max(1, varAmo - 1);
				
				switch(v.type) {
					case VALUE_TYPE.color : 
						if(type == 0 && is(gradient, gradientObject)) // gradient
							_val = gradient.eval(_rat);
							
						else if(type == 1 && !array_empty(palette)) // palette
							_val = array_safe_get(palette, round((array_length(palette) - 1) * _rat));
						
						break;
						
					case VALUE_TYPE.boolean : 
						_val = _rat > .5;
						break;
					
					case VALUE_TYPE.text : 
						if(v.display_type == VALUE_DISPLAY.enum_string) {
							var _chs = v.getChoices();
							var  ind = round(_rat * max(0, array_length(_chs) - 1));
							_val = array_safe_get_fast(_chs, ind);
						}
						break;
						
					default : 
						if(is_numeric(min_val)) {
							_val = lerp(min_val, max_val, _rat);
							if(round_val) _val = round(_val);
							
						} else if(is_array(min_val)) {
							_val = array_create(array_length(min_val));
							for( var j = 0, m = array_length(min_val); j < m; j++ )
								_val[j] = lerp(min_val[j], max_val[j], _rat);
						}		
				}
				
				varients[i] = _val;
			}
		}
		
		static setVarients = function(_i) { 
			var _v = getValue();
			if(!is(_v, NodeValue)) return 0;
			
			varIndex = _i; 
			var _val = varients[varIndex];
			if(_val != undefined) _v.setValue(_val);
			
			if(bindNode) bindNode.triggerRender();
		}
		
		static Random = function() /*=>*/ {
			randomize();
			varIndex = -1;
			
			var v = getValue();
			if(!is(v, NodeValue)) return 0;
			
			var _val = undefined;
			
			switch(v.type) {
				case VALUE_TYPE.color : 
					if(type == 0 && is(gradient, gradientObject)) // gradient
						_val = gradient.eval(random(1));
						
					else if(type == 1 && !array_empty(palette)) // palette
						_val = array_safe_get(palette, irandom(array_length(palette) - 1));
					break;
				
				case VALUE_TYPE.boolean : 
					_val = choose(0,1);
					break;
				
				case VALUE_TYPE.text : 
					if(v.display_type == VALUE_DISPLAY.enum_string) {
						var _chs = v.getChoices();
						_val = array_get_random(_chs);
					}
					break;
					
				default : 
					if(is_numeric(min_val)) {
						_val = random_range(min_val, max_val);
						if(round_val) _val = round(_val);
						
					} else if(is_array(min_val)) {
						_val = array_create(array_length(min_val));
						
						for( var i = 0, n = array_length(min_val); i < n; i++ )
							_val[i] = random_range(min_val[i], max_val[i]);
					}		
			}
			
			if(_val != undefined) v.setValue(_val);
			return _val;
		}
		
		////- =Serialize
		
		static serialize = function() {
			var _m = {};
			
			_m.data    = "random";
			
			_m.varients = array_clone(varients);
			_m.varIndex = varIndex;
			_m.varUse   = varUse;
			_m.varRand  = varRand;
			_m.varAmo   = varAmo;
			
			_m.node_id = node_id;
			_m.inindex = inindex;
			
			_m.name    = name;
			_m.type    = type;
			
			_m.palt    = palette;
			_m.grad    = gradient? gradient.serialize() : 0;
			
			_m.min_val = min_val;
			_m.max_val = max_val;
			
			return _m;
		}
		
		static deserialize = function(_m) {
			varients = array_clone(_m[$ "varients"] ?? varients);
			varIndex = _m[$ "varIndex"] ?? varIndex;
			varUse   = _m[$ "varUse"]   ?? varUse;
			varRand  = _m[$ "varRand"]  ?? varRand;
			varAmo   = _m[$ "varAmo"]   ?? varAmo;
			
			node_id = _m[$ "node_id"] ?? node_id;
			inindex = _m[$ "inindex"] ?? inindex;
			
			name    = _m[$ "name"] ?? name;
			type    = _m[$ "type"] ?? type;
			
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
		
		static refreshContent = function() {
			var _currSec = undefined;
			
			for( var i = 0, n = array_length(values); i < n; i++ ) {
				var _trk = values[i];
				
				if(is(_trk, Project_Randomizer_Section)) {
					_currSec = _trk;
					_currSec.contents = [];
				}
				
				if(is(_trk, Project_Randomizer_Value)) {
					var _nod = _trk.getNode();
					if(!is(_nod, Node) || !_nod.active) continue;
					
					if(_currSec) array_push(_currSec.contents, _trk);
				}
			}
			
		}
		
		////- Serialize
		
		static serialize = function() {
			var _m = {};
			
			_m.values = [];
			for( var i = 0, n = array_length(values); i < n; i++ ) {
				var _trk = values[i];
				
				if(is(_trk, Project_Randomizer_Value)) {	
					var _nod = _trk.getNode();
					if(!is(_nod, Node) || !_nod.active) continue;
				}
				
				array_push(_m.values, _trk.serialize() );
			}
			return _m;
		}
		
		static deserialize = function(_data) {
			values = array_map(_data.values, function(v,i) /*=>*/ {return new Project_Randomizer_Track().deserialize(v)});
			run_in(2, function() /*=>*/ {return refreshContent()});
			return self;
		}
	}
	
	function Project_Randomizer_Varient_Reset(_project = PROJECT) {
		var _nodes = _project.allNodes;
		for( var i = 0, n = array_length(_nodes); i < n; i++ ) {
			var node = _nodes[i];
			if(is(node, Node_Randomizer_Varient_Collect)) node.resetArray();
		}
	}
#endregion

function Panel_Randomizer() : PanelContent() constructor {
	title = "Randomizer";
	w = ui(640);
	h = ui(320);
	
	curr_project = undefined;
	curr_amo     = 0;
	
	toRefresh    = true;
	
	auto_pin   = true;
	editing    = false;
	randActive = false;
	
	section_list = [];
	section_var_setting = undefined;
	
	dragging       = false;
	dragging_track = undefined;
	
	name_editing = undefined;
	name_editor  = textBox_Text(function(txt) /*=>*/ {
		if(name_editing == undefined) return;
		name_editing.name = txt;
		name_editing = undefined;
	})
	
	////- Random
	
	sc_randomize = new scrollPane(1, 1, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww  = sc_randomize.surface_w;
		
		var _rnd  = PROJECT.randomizer;
		var _trks = _rnd.values;
		
		var group_labels = [];
		var currSec      = undefined;
		
		var sectColl = false;
		
		var pd = ui(6);
		var hg = ui(24);
		var xx = 0;
		var x1 = ww - pd;
		var yy = _y + ui(8);
		
		var edw = x1 * .4;
			
		var bs = hg;
		var bc = [COLORS._main_icon, COLORS._main_icon_light];
		
		var rx = x + sc_randomize.x;
		var ry = y + sc_randomize.y;
		
		var eh = hg - ui(4);
		var _del = undefined;
	
		var hov = sc_randomize.hover;
		var foc = sc_randomize.active;
		
		var drag_hover_index       = 0;
		var _section_var_hover     = undefined;
		var _section_var_hover_ind = undefined;	
		
		#region section bg
			var len = array_length(section_list);
			if(len && section_list[0].y < hg) {
				draw_set_color(COLORS.panel_bg_clear_inner);
				if(_m[1] >= section_list[0].y && _m[1] <= section_list[0].y + hg + ui(4))
					hov = false;
			}
			
			var len = array_length(section_list);
			for( var i = 0, n = array_length(section_list); i < n; i++ ) {
				var lb = section_list[i];
				var _name = lb.name;
				var _coll = lb.coll && !editing;
				
				var _lbh  = lb.y1 - lb.y;
				
				var scx = 0;
				var scy = lb.y;
				var scw = ww;
				var sch = hg;
				
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
				
				yy += hg;
				continue;
			}
		
			if(sectColl) continue;
			
			if(!is(_trk, Project_Randomizer_Value)) continue;
			
			var _nod = _trk.getNode();
			if(!is(_nod, Node) || !_nod.active) continue;
			
			var _val = _trk.getValue();
			if(!is(_val, NodeValue)) continue;
			
			var _nnam = _nod.getDisplayName();
			var _vnam = _trk.name == ""? _val.getName() : _trk.name;
			
			var hgh = hg;
			var tx  = pd;
			var thh = _trk.h;
			
			var hv  = hov && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + thh - 1);
			var by  = yy + hg / 2 - bs / 2;
			
			if(hv) {
				draw_sprite_stretched_ext(THEME.box_r2, 0, ui(4), yy, ww - ui(8), thh, COLORS._main_icon, .1);
				if(_m[0] < edw && foc && DOUBLE_CLICK) inspectorFocusProp(_val);
			}
			
			if(editing) {
				var bx = tx;
				var bc = COLORS._main_icon;
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.hamburger_s, 0, bc, 1, ui(10)) == 2) {
					dragging       = true;
					dragging_track = _trk;
				}
				tx += bs;
				
			} else 
				tx += ui(4);
			
			var spr = _nod.getMetaSpr();
			if(spr) {
				var ss = (hgh - ui(8)) / sprite_get_height(spr);
				draw_sprite_ext(spr, 0, tx + hgh / 2, yy + hg / 2, ss, ss);
			}
			
			tx += hgh + ui(4);
			
			draw_set_text(f_p3, fa_left, fa_center);
			if(!editing) {
				draw_set_color(COLORS._main_text_sub);
				draw_text_add(tx, yy + hg / 2, _nnam);
				tx += string_width(_nnam) + ui(4)
			}
			
			draw_set_color(COLORS._main_text);
			draw_text_add(tx, yy + hg / 2, _vnam);
			
			var bx = x1 - bs;
			var _vars = _trk.varients;
			var _vind = _trk.varIndex;
			
			if(!editing) {
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Randomize"), THEME.icon_random, 0, bc, 1, ui(6)) == 2)
					_trk.Random();
				bx -= ui(4);
				
				if(_trk.varUse) {
					var vs  = ui(10);
					var vx  = bx - ui(4) - vs;
					var vy  = yy + hg / 2 - vs / 2;
					
					var vpd = ui(1);
					var vx0 = pd + edw;
				
					for( var j = 0, m = array_length(_vars); j < m; j++ ) {
						var v  = m-1-j;
						var vh = hov && point_in_rectangle(_m[0], _m[1], vx - vpd, vy - vpd, vx + vs + vpd, vy + vs + vpd);
						if(section_var_setting == _trk)  vh = hov && _m[0] >= vx - vpd && _m[0] <= vx + vs + vpd;
						
						if(v == _vind)
							draw_sprite_stretched_ext(THEME.palette_mask, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
							
						draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, .75);
						if(vh) {
							setTOOLTIP([string(_vars[v]), _val.type]);
							draw_sprite_stretched_add(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
							
							if(mouse_lpress(foc)) section_var_setting = _trk;
							if(section_var_setting == _trk) _trk.setVarients(v);
						}
						
						if(v == _trk.varHigh)
							draw_sprite_stretched_ext(THEME.palette_mask, 1, vx, vy, vs, vs, COLORS._main_accent, 1);
							
						vx -= vs + vpd*2 + 1;
						
						if(vx < vx0) {
							draw_set_text(f_p4, fa_right, fa_center, COLORS._main_text_sub);
							draw_text_add(vx + vs - ui(2), vy + vs / 2 - ui(1), $"+{m-j}");
							break;
						}
					}
				}
				
				_trk.varHigh = undefined;
				
			} else {
				var bc = [COLORS._main_icon, COLORS._main_value_negative];
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Delete"), THEME.cross_16, 0, bc, 1, ui(6)) == 2)
					_del = i;
				bx -= bs + ui(2);
				
				var bc = _trk.varUse? COLORS._main_accent : [COLORS._main_icon, COLORS._main_icon_light];
				if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Variant"), THEME.icon_random_varient, 0, bc, 1, ui(8)) == 2) {
					_trk.varUse = !_trk.varUse;
					if(_trk.varUse) _trk.generateVarients();
				}
				bx -= ui(4);
				
				var _typeWidget = _trk.typeWidget;
				var _editWidget = _trk.getEditWidget();
				
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
					var ew = (edw - ui(4)) / 2;
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
				
				if(_trk.varUse) {
					var vs = ui(10);
					var vx = tx;
					var vy = yy + hg + hg / 2 - vs / 2;
					
					var vpd = ui(1);
					var vpx = edw - vs - ui(8);
					
					for( var j = 0, m = array_length(_vars); j < m; j++ ) {
						var v  = j;
						var vh = hov && point_in_rectangle(_m[0], _m[1], vx - vpd, vy - vpd, vx + vs + vpd, vy + vs + vpd);
						
						if(v == _vind)
							draw_sprite_stretched_ext(THEME.palette_mask, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
							
						draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, .75);
						if(vh) {
							setTOOLTIP([string(_vars[v]), _val.type]);
							draw_sprite_stretched_add(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
							if(mouse_lclick(foc)) _trk.setVarients(v);
						}
						
						vx += vs + vpd*2 + 1;
						
						if(vx > vpx) {
							draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text_sub);
							draw_text_add(vx + ui(2), vy + vs / 2 - ui(1), $"+{m-j}");
							break;
						}
					}
					
					var vew = edw;
					var veh = hg;
					
					var vex = bx - vew;
					var vey = yy + veh + ui(2);
					
					var vx0 = vex;
					var vx1 = vex + vew;
					
					by = vey;
					bs = veh;
					
					bx = vex;
					bc = _trk.varRand? COLORS._main_accent : COLORS._main_icon;
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Random"), THEME.icon_random, 0, bc, 1, ui(6)) == 2) {
						_trk.varRand = !_trk.varRand;
						_trk.generateVarients();
					}
					bx += bs + ui(2);
					vx0 = bx;
					
					bx = vx1;
					bc = COLORS._main_value_positive;
					
					bx -= bs;
					var bc = [COLORS._main_icon, COLORS._main_value_positive];
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Regenerate"), THEME.refresh_16, 0, bc, 1, ui(6)) == 2)
						_trk.generateVarients();
					bx -= ui(2);
					vx1 = bx;
					
					var vedt = _trk.getVarEdit();
					var vedx = vx0;
					var vedy = vey + hg / 2 - eh / 2;
					var vedw = vx1 - vx0;
					var vedh = eh;
					
					var bw   = vedw - bs - ui(2);
					var dp   = new widgetParam(vedx, vedy, vedw, vedh, _trk.varAmo, undefined, _m, rx, ry).setFont(f_p3);
					
					vedt.register(sc_randomize);
					vedt.setFocusHover(foc, hov);
					vedt.drawParam(dp);
					
					hgh += veh + ui(4);
				}
				
			}
			
			_trk.h = hgh;
			
			if(currSec) currSec.y1 = max(currSec.y1, yy + hgh + ui(2));
			yy += hgh;
		}
		
		if(_m[1] > yy) drag_hover_index = n-1;
		
		#region section label
			var len = array_length(group_labels);
			if(len && group_labels[0].y < hg) {
				draw_set_color(COLORS.panel_bg_clear_inner);
				draw_rectangle(0, group_labels[0].y, ww, hg, false);
			}
			
			var _cAll = 0;
			var scs = gpu_get_scissor();
			var hov = sc_randomize.hover;
			
			for( var i = 0; i < len; i++ ) {
				var lb = group_labels[i];
				var _name = lb.name;
				var _coll = lb.coll && !editing;
				
				var _yy   = max(lb.y, i == len - 1? ui(2) : min(ui(2), group_labels[i + 1].y - ui(32)));
				var _hv   = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + hg);
				var _lbh  = lb.y1 - _yy;
				
				var scx = 0;
				var scy = _yy;
				var scw = ww;
				var sch = hg;
				
				if(_coll) {
					draw_sprite_stretched_ext(THEME.section_separator, 0, scx, scy, scw, _coll? sch : _lbh, COLORS.section_bg);
					
				} else {
					gpu_set_scissor(scx, 0, scw, hg+1);
					draw_sprite_stretched_add(THEME.box_r5, 0, scx, scy, scw, _lbh, COLORS.panel_bg_clear, .2);
					gpu_set_scissor(scs);
    				
            		var hovCnt = pHOVER && point_in_rectangle(_m[0], _m[1], scx, scy, scx + scw, scy + _lbh);
            		if(hovCnt) draw_sprite_stretched_add(THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover, .4);
				}
        		
            	if(!_coll) draw_sprite_stretched_ext( THEME.section_separator, 2, scx, scy, scw, sch, COLORS.section_selected  );
            	if(_hv) {
            		draw_sprite_stretched_ext( THEME.section_separator, 3, scx, scy, scw,  sch, COLORS.section_hover, .2 );
            		draw_sprite_stretched_ext( THEME.section_separator, 1, scx, scy, scw, _lbh, COLORS.section_hover     );
            		
            		if(mouse_rpress(foc)) {
            			menuCall("", [
            				menuItem(__txt("Create Node"), function(_trk) /*=>*/ { 
            					var _node = nodeBuild("Node_Randomizer_Varient", PANEL_GRAPH.graph_cx, PANEL_GRAPH.graph_cy);
            					_node.skipDefault();
            					_node.inputs[0].setValue(_trk.name);
            				}).setParam(lb)
        				]);
            		}
            	}
				
				var _vars = lb.varients;
				var _vind = lb.varIndex;
			
				var bx = x1 - bs;
				var by = scy + sch / 2 - bs / 2;
				
				if(!editing) {
					var bc = [COLORS._main_icon, COLORS._main_icon_light];
					var bt = __txt("Randomize Section");
					var bb = buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, bt, THEME.icon_random, 0, bc, 1, ui(6));
					if(bb) _hv = false;
					if(bb == 2) randomizeSection(lb);
					bx -= ui(4);
					
				} else {
					var bx = pd;
					var bc = COLORS._main_icon;
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, "", THEME.hamburger_s, 0, bc, 1, ui(10)) == 2) {
						dragging       = true;
						dragging_track = lb;
					} tx += bs;
					
					var bx = x1 - bs;
					var bc = [COLORS._main_icon, COLORS._main_value_negative];
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, __txt("Delete"), THEME.cross_16, 0, bc, 1, ui(6)) == 2)
						_del = lb.indx;
					bx -= bs + ui(2);
					
					var bc = [COLORS._main_icon, COLORS._main_value_positive];
					var bt = __txt("Generate Variants");
					if(buttonInstant_Pad(noone, bx, by, bs, bs, _m, hov, foc, bt, THEME.icon_random_varient_refresh, 0, bc, 1, ui(8)) == 2)
						lb.generateVarients();
					bx -= ui(4);
					
				}
				
				var edw = x1 * .4;
				var vs  = ui(10);
				var vx  = bx - ui(4) - vs;
				var vy  = scy + sch / 2 - vs / 2;
				var vx0 = pd + edw;
				
				var vpd = ui(1);
				
				for( var j = 0, m = array_length(_vars); j < m; j++ ) {
					var v  = m-1-j;
					var vh = hov && point_in_rectangle(_m[0], _m[1], vx - vpd, vy - vpd, vx + vs + vpd, vy + vs + vpd);
					if(section_var_setting == lb) vh = hov && _m[0] >= vx - vpd && _m[0] <= vx + vs + vpd;
					
					if(v == _vind)
						draw_sprite_stretched_ext(THEME.palette_mask, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
						
					draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, .75);
					if(vh) {
						_hv = false;
						_section_var_hover     = lb;
						_section_var_hover_ind = _vars[v];
						
						draw_sprite_stretched_add(THEME.palette_mask_outline, 1, vx, vy, vs, vs, COLORS._main_icon, 1);
						
						if(mouse_lpress(foc)) section_var_setting = lb;
						if(section_var_setting == lb) lb.setVarients(v);
					}
					
					vx -= vs + vpd*2 + 1;
					
					if(vx < vx0) {
						draw_set_text(f_p4, fa_right, fa_center, COLORS._main_text_sub);
						draw_text_add(vx + vs - ui(2), vy + vs / 2 - ui(1), $"+{m-j}");
						break;
					}
				}
				
				if(!editing) {
					if(_hv && pFOCUS) {
	                	if(DOUBLE_CLICK) 
	                		_cAll = _coll? -1 : 1;
	                		
	                	else if(mouse_lpress()) 
	                    	lb.coll = !lb.coll;
					}
                }
	                
				if(editing) {
					draw_set_text(f_p3, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
					var tx = pd + bs + ui(4);
					var ty = _yy + hg / 2
					
					var tw = string_width(_name)  + ui(4);
					var th = string_height(_name) + ui(4);
					
					var tx0 = tx  - ui(2);
					var tx1 = tx0 + tw;
					var ty0 = ty  - th / 2;
					var ty1 = ty  + th / 2;
					
					if(name_editing == lb) {
						name_editor.setFocusHover(pFOCUS, pHOVER);
						name_editor.drawParam(new widgetParam(tx0, ty0, bx - tx0 - ui(8), th, _name, undefined, _m).setFont(f_p3));
						
					} else {
						draw_text_add(tx, ty, _name);
						
						if(pHOVER && point_in_rectangle(_m[0], _m[1], tx0, ty0, tx1, ty1)) {
							draw_sprite_stretched_ext(THEME.box_r2_clr, 1, tx0, ty0, tx1 - tx0, ty1 - ty0);
							if(mouse_lpress(pFOCUS)) {
								name_editing = lb;
								name_editor.activate(_name);
							}
						}
					}
					
				} else {
					draw_sprite_ui(THEME.arrow, _coll? 0 : 3, ui(16), _yy + hg / 2, 1, 1, 0, COLORS._main_text_sub, 1);    
				
					draw_set_text(f_p3, fa_left, fa_center, _hv? COLORS._main_text : COLORS._main_text_sub);
					draw_text_add(ui(28), _yy + hg / 2, _name);
				}
			}
			
				 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) group_labels[i].coll = false; } 
			else if(_cAll == -1) { for( var i = 0; i < len; i++ ) group_labels[i].coll =  true; }
			
			section_list = group_labels;
		#endregion
    	
    	if(_section_var_hover) {
    		var _cnt = _section_var_hover.contents;
    		var _ind = _section_var_hover_ind;
    		var _amo = min(array_length(_cnt), array_length(_ind));
    		
    		for( var i = 0; i < _amo; i++ ) {
    			var _tr = _cnt[i];
    			var _in = _ind[i];
    			
    			_tr.varHigh = _in;
    		}
    	}
    	
		if(section_var_setting && mouse_lrelease()) section_var_setting = undefined;
		
		if(_del != undefined) array_delete(_trks, _del, 1);
		
		if(dragging) {
			array_remove(_trks, dragging_track);
			array_insert(_trks, drag_hover_index, dragging_track);
			toRefresh = true;
			
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
	
	static randomizeSection = function(_sect) {
		_sect.varIndex = -1;
		for( var i = 0, n = array_length(_sect.contents); i < n; i++ )
			_sect.contents[i].Random();
	}
	
	////- Step
	
	static stepBegin = function() {
		if(randActive) RANDOMIZER_ACTIVE = self;
		randActive = false;
	}
	
	////- Draw
	
	function drawContent(panel) {
		randActive = true;
		
		if(curr_project != PROJECT || curr_amo != array_length(PROJECT.randomizer.values)) {
			curr_project = PROJECT;
			curr_amo     = array_length(PROJECT.randomizer.values);
			toRefresh    = true;
		}
		
		if(toRefresh) {
			curr_project.randomizer.refreshContent();
			toRefresh = false;
		}
		
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var _rnd = PROJECT.randomizer;
		
		var bs  = ui(24);
		var m   = [mx,my];
		var hov = pHOVER;
		var foc = pFOCUS;
		
		var bb = THEME.button_hide;
		var bc = COLORS._main_accent;
		var by = ui(8);
		
		var bx = w - ui(8) - bs;
		var bt = __txt("Randomize All");
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, bt, THEME.icon_random, 0, bc) == 2)
			_rnd.Random();
		bx -= bs + ui(4);
		
		var bt = __txt("Randomize Selected nodes seed");
		var bc = COLORS._main_icon;
		var ac = !array_empty(PANEL_GRAPH.nodes_selecting);
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, ac && hov, foc, bt, THEME.icon_random_seed, 0, bc, .5 + ac*.5) == 2)
			randomSeed();
		bx -= bs + ui(4);
		
		var n = PANEL_INSPECTOR.getInspecting();
		var bx = ui(8);
		
		bc = editing? COLORS._main_value_positive : COLORS._main_icon;
		if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Edit"), THEME.gear_16, 0, bc) == 2)
			editing = !editing;
		bx += bs + ui(4);
		
		if(editing) {
			bc = [COLORS._main_icon, COLORS._main_value_positive];
			if(buttonInstant_Pad(bb, bx, by, bs, bs, m, hov, foc, __txt("Add Section"), THEME.tag, 0, bc, 1, ui(8)) == 2) {
				PROJECT.randomizer.addTrack(new Project_Randomizer_Section("New Section"))
				toRefresh = true;
			}
			bx += bs + ui(4);
		}
		
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