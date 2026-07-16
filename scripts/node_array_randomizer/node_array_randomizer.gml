function RandomizedArray() : ArrayObject() constructor {
	content = [];
	
	weights     = [];
	weightTotal = 0;
	
	static getElementByIndex = function(i) /*=>*/ {return content[i]};
	static getElementRandom  = function( ) /*=>*/ {
		if(length == 0) return noone;
		var _w = random(weightTotal);
		var _i = array_search_min_bin(weights, _w);
		return array_safe_get(content, _i);
	}
	
	static getIndexRandom    = function( ) /*=>*/ {
		if(length == 0) return 0;
		var _w = random(weightTotal);
		var _i = array_search_min_bin(weights, _w);
		return _i;
	}
	
}

function Node_Array_Randomizer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Weighted Selector";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue("Array in", self, CONNECT_TYPE.input, VALUE_TYPE.any, []) ).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array Selector", VALUE_TYPE.any, new RandomizedArray() ));
	
	weight_min =  infinity;
	weight_max = -infinity;
	
	weightList = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _arr  = getInputData(0);
		var _aLen = array_safe_length(_arr);
		var _wAmo = getInputAmount();
		
		var  len  = min(_aLen, _wAmo);
		var _type = inputs[0].type;
		
		var pad = ui(8);
		var hg  = ui(32);
		var _pd = ui(3);
		
		var _h = len * hg + pad * 2;
		var ww = _w - pad * 2;
		var rx = weightList.rx;
		var ry = weightList.ry;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for( var i = 0; i < len; i++ ) {
			var wx = _x + pad;
			var wy = _y + pad + i * hg;
			
			var _ind = input_fix_len + i * data_length;
			var _wei = getInputData(_ind);
			
			var _val = _arr[i];
			var _sx  = wx + _pd;
			var _sy  = wy + _pd;
			var _ss  = hg - _pd * 2;
			
			if(_type == VALUE_TYPE.surface && is_surface(_val)) {
				var sw = surface_get_width_safe(_val);
				var sh = surface_get_height_safe(_val);
				var ss = min(_ss / sw, _ss / sh);
				
				var ssx = _sx + _ss / 2 - sw * ss / 2;
				var ssy = _sy + _ss / 2 - sh * ss / 2;
				
				draw_surface_ext_safe(_val, ssx, ssy, ss, ss);
			}
			
			draw_sprite_stretched_ext(THEME.box_r2, 1, _sx, _sy, _ss, _ss, COLORS._main_icon, .75);
			
			var tx = wx + _ss + ui(12);
			var ty = wy + hg / 2;
			
			draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(tx, ty, i);
			
			var wdw = ww * .5;
			var wdh = _ss;
			
			var wdx = _x + _w - pad - wdw;
			var wdy = wy + hg / 2 - wdh / 2;
			
			var wdgt = inputs[_ind].getEditWidget();
			if(!is(wdgt, widget)) continue;
			
			var barw = clamp((_wei - 0) / (weight_max - 0), 0, 1) * wdw;
			
			wdgt.setFocusHover(_focus, _hover);
			wdgt.setHide(1);
			
			draw_sprite_stretched_ext(THEME.textbox, 4, wdx, wdy, barw, wdh, c_white, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, wdx, wdy, wdw,  wdh, c_white, .5 + .5 * weightList.interactable);
			
			if(weightList.interactable)
				wdgt.drawParam(new widgetParam(wdx, wdy, wdw, wdh, _wei, undefined, _m, rx, ry).setFont(f_p3));
			else {
				draw_set_text(f_p3, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_add(wdx + wdw / 2, wdy + wdh / 2, _wei);
			}
			
			if(_wei < 0) draw_sprite_stretched_ext(THEME.textbox, 2, wdx, wdy, wdw,  wdh, COLORS._main_value_negative, .5);
			
			draw_sprite_ui(THEME.icon_random, 0, wdx - ui(4 + 12), ty, .75, .75, 0, COLORS._main_icon);
		}
		
		return _h;
	});
	
	input_display_list = [
		[ "Array",   false ], 0, 
		[ "Weights", false ], weightList, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_Float( "Weight", 1 ));
		return inputs[index];
	} setDynamicInput(1, false);
	
	////- Node
	
	static refreshWeights = function(_len) {
		var _wamo = getInputAmount();
		if(_len == _wamo) return;
		
		if(_len < _wamo) {
			array_resize(inputs, _len);
		}
		
		if(_len > _wamo) {
			var _addAmo = _len - _wamo;
			repeat(_addAmo) createNewInput();
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var arr = getInputData(0);
		if(!is_array_safe(arr)) { noti_warning($"{name}: Input not an array", noone, self); return; }
		
		var _alen = array_safe_length(arr);
		refreshWeights(_alen);
		
		var _rarr = new RandomizedArray();
		_rarr.content = arr;
		_rarr.length  = _alen;
		
		var _weight  = [];
		var _weiAccu = 0;
		
		weight_min =  infinity;
		weight_max = -infinity;
		
		for( var i = 0, n = getInputAmount(); i < n; i++ ) {
			var _ind = input_fix_len + i * data_length;
			var _w = getInputData(_ind);
			
			weight_min = min(weight_min, _w);
			weight_max = max(weight_max, _w);
			
			_weight[i] = _weiAccu;
			_weiAccu  += _w;
		}
		
		_rarr.weights     = _weight;
		_rarr.weightTotal = _weiAccu;
		_rarr.drawWidget  = weightList;
		
		outputs[0].setValue(_rarr);
	}
	
	////- Draw
	
	outputs[0].drawJunction = method(outputs[0], function(_s, _mx, _my, _aa = 1) { 
		var _hov = hover_in_graph || (draw_group_object != undefined && draw_group_object[3]);
		_s /= 2 * THEME_SCALE;
		
		var _cbg = draw_bg;
		var _cfg = custom_color ?? draw_fg;
		
		if(draw_blend != -1) {
			_cbg = merge_color(draw_blend_color, _cbg, draw_blend);
			_cfg = merge_color(draw_blend_color, _cfg, draw_blend);
		}
		
		var _bgS = THEME.node_junctions_bg;
		var _fgS = _hov? THEME.node_junctions_outline_hover : THEME.node_junctions_outline;
		
		if(graph_selecting) {
			var ss = _s * THEME_SCALE;
			__draw_sprite_ext(THEME.node_junction_selecting, 0, x, y, ss, ss, 0, _cfg, _aa * .8);
			graph_selecting = false;
		}
		
		var ds = _s * .75;
		var sh = 5 * _s;
		
		__draw_sprite_ext(_bgS, draw_junction_index, x + sh, y + sh, ds, ds, 0, _cbg, _aa);
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
		__draw_sprite_ext(_fgS, draw_junction_index, x + sh, y + sh, ds, ds, 0, _cfg, _aa);
		gpu_set_blendmode(bm_normal);
		
		__draw_sprite_ext(_bgS, draw_junction_index, x - sh, y - sh, ds, ds, 0, _cbg, _aa);
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
		__draw_sprite_ext(_fgS, draw_junction_index, x - sh, y - sh, ds, ds, 0, _cfg, _aa);
		gpu_set_blendmode(bm_normal);
	});
}