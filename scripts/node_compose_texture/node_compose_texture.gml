function Node_Compose_Texture(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Compose Texture";
	
	////- Surface
	newInput( 0, nodeValue_Surface( "Base Surface" ));
	
	////- Composing
	newInput( 1, nodeValue_Slider( "Threshold", .1 ));
	// 2
	
	newOutput( 0, nodeValue_Output("Composed", VALUE_TYPE.surface, noone ));
	
	text_h        = undefined;
	text_dragging = undefined;
	text_drag     = 0;
	text_drag_my  = 0;
	
	add_effect_index = 0;
	effect_dragging  = undefined;
	effect_drag_par  = undefined;
	effect_drag      = 0;
	effect_drag_my   = 0;
	
	texture_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		PROCESSOR_OVERLAY_CHECK
		
		var lor = attributes.layer_order;
		var amo = array_length(lor);
		var hg  = ui(28);
		var fhg = ui(24);
		var _h  = ui(16);
		
		if(text_h != undefined)
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, text_h, COLORS.node_composite_bg_blend, 1);
		
		var ss = hg - ui(4);
		var cw = _w - ui(16) - ss - ui(24) - ss - ui(4);
		
		var yy    = _y + ui(8);
		var _ax   = _x + ui(8);
		var _ay   = yy;
		
		var _insi = 0;
		var _insy = yy;
		
		var _inei = 0;
		var _iney = yy;
		
		for( var i = 0; i < amo; i++ ) {
			var ind = attributes.layer_order[i];
			var _ay = yy;
			
			var _hh = hg;
			
			var _ind = input_fix_len + ind * data_length;
			var _tex = getInputSingle(_ind + 0);
			var _tar = getInputSingle(_ind + 1);
			
			var sel = dynamic_input_inspecting == ind;
			var hov = _hover && point_in_rectangle(_m[0], _m[1], 0, _ay, _w - ss, _ay + hg - 1);
			
			var sx = _ax;
			var sy = _ay;
			
			var shv = _hover && point_in_rectangle(_m[0], _m[1], sx, sy, sx + cw, sy + ss);
			if(sel) draw_sprite_stretched_add(THEME.box_r2, 1, sx, sy, cw, ss, COLORS._main_accent, 1);
			else    draw_sprite_stretched_add(THEME.box_r2, 1, sx, sy, cw, ss, COLORS._main_icon, 0.3);
			draw_sprite_stretched_add(THEME.box_r2, 0, sx+ui(2), sy+ui(2), cw-ui(4), ss-ui(4), _tar, 1);
			if(shv) {
				draw_sprite_stretched_add(THEME.box_r2, 1, sx+ui(2), sy+ui(2), cw-ui(4), ss-ui(4), COLORS._main_icon, 1);
			}
			
			sx += cw + ui(12);
			draw_sprite_ui(THEME.arrow, 0, sx, sy+ss/2, 1, 1, 0, COLORS._main_icon, 1);
			
			sx += ui(12);
			
			if(is_just_surface(_tex)) {
				var _sw = surface_get_width(_tex);
				var _sh = surface_get_height(_tex);
				
				var _ss = ss / max(_sw, _sh);
				var _sx = sx + ss / 2 - _sw * _ss / 2;
				var _sy = sy + ss / 2 - _sh * _ss / 2;
				
				draw_surface_ext(_tex, _sx, _sy, _ss, _ss, 0, c_white, 1);
			}
			
			if(sel) draw_sprite_stretched_add(THEME.box_r2, 1, sx, sy, ss, ss, COLORS._main_accent, 1);
			else    draw_sprite_stretched_add(THEME.box_r2, 1, sx, sy, ss, ss, COLORS._main_icon, 0.3);
			
			var bx = _x + _w - ui(8) - ss;
			var by = _ay;
			
			if(buttonInstant(THEME.button_hide, bx, by, ss, ss, _m, _hover, _focus, __txt("Add Effect"), THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				var dx  = mouse_mx + 8;
				var dy  = mouse_my + 8;
				var ctx = self;
				var dia = instance_create_depth(dx, dy, 0, o_dialog_add_node, { context: ctx });
				add_effect_index = ind;
				
				if(dia) dia.buildCallback = function(newNode) /*=>*/ {
					array_push(attributes.layer_effect[add_effect_index], newNode.node_id);
					add(newNode)
					
					dialogPanelCall(new Panel_Inspector().setInspecting(newNode, true))
				}
			}
			
			var _effs = attributes.layer_effect[ind];
			if(effect_drag_par == i) {
				_inei = 0;
				_iney = _ay + hg;
			}
			
			if(!array_empty(_effs)) {
				var ey = _ay + hg;
				
				var ex = _x + ui(16);
				var ew = _w - ui(16 + 8);
				
				var toDel = undefined;
				
				for( var j = 0, m = array_length(_effs); j < m; j++ ) {
					var _eff = _effs[j];
					var _eno = layer_effect_map[$ _eff];
					if(!is(_eno, Node)) continue;
					
					ew = _w - ui(16 + 8);
					
					#region side buttons
						var bx = _x + _w - ui(8);
						var by = ey;
						
						bx -= fhg; ew -= fhg;
						if(buttonInstant(THEME.button_hide, bx, by, fhg, fhg, _m, _hover, _focus, __txt("Remove Effect"), 
							THEME.icon_delete, 0, CARRAY.button_negative, 1, 1) == 2) {
								
							_eno.destroy();
							toDel = j;
						}
						
						bx -= fhg + ui(2); ew -= fhg + ui(2);
						if(_eno.input_mask_index >= 0) {
							var _umsk = bool(_eno.attributes[$ "effect_use_mask"]);
							if(buttonInstant(THEME.button_hide, bx, by, fhg, fhg, _m, _hover, _focus, __txt("Mask Under"), 
								THEME.shader_alpha, _umsk, COLORS._main_icon, 1, .75) == 2) {
								
								_eno.attributes[$ "effect_use_mask"] = !_umsk;
								triggerRender();
							}
						}
						
						ew -= ui(2);
					#endregion
					
					var _name = _eno.getDisplayName();
		    		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
		    		draw_text_add(ex + ui(24), ey + fhg/2, _name);
				    		
		    		var _ic = _eno.getMetaSpr();
		    		var _ss = (fhg - ui(4)) / sprite_get_width(_ic);
		    		draw_sprite_ext(_ic, 0, ex + ui(12), ey + fhg / 2, _ss, _ss);
    				
		    		var _hov = _hover && point_in_rectangle(_m[0], _m[1], ex, ey, ex + ew, ey + fhg);
		    		if(_hov) {
		    			draw_sprite_stretched_add(THEME.box_r5, 1, ex, ey, ew, fhg, c_white, .2);
		    			if(mouse_lpress(_focus)) {
		    				dialogPanelCall(new Panel_Inspector().setInspecting(_eno, true));
		    				
							effect_dragging = _eff;
							effect_drag_par = i;
							effect_drag     = 1;
							effect_drag_my  = _m[1];
		    			}
		    			
		    			if(effect_drag_par == i) {
							if(_m[1] > ey + fhg / 2) {
								_inei = j+1;
								_iney = ey + fhg;
								
							} else {
								_inei = j;
								_iney = ey;
							}
							
						}
						
		    		}
		    		
		    		 ey += fhg;
		    		_hh += fhg;
				}
				
				if(toDel) {
					array_delete(_effs, toDel, 1);
					triggerRender();
				}
				
				if(effect_drag_par == i && _m[1] > ey) {
					_inei = m-1;
					_iney = ey;
				}
				
				_hh += ui(2);
			}
			
			if(hov) {
				if(_m[1] > _ay + _hh / 2) {
					_insi = i+1;
					_insy = _ay + _hh;
					
				} else {
					_insi = i;
					_insy = _ay;
				}
				
				if(mouse_lpress(_focus)) {
					dynamic_input_inspecting = sel? noone : ind;
					refreshDynamicDisplay();
					
					text_dragging = ind;
					text_drag     = 1;
					text_drag_my  = _m[1];
				}
			}
			
			yy += _hh;
			_h += _hh;
		}
		
		#region Drag Texture
			if(text_drag == 2) {
				if(_m[1] > _ay) {
					_insi = amo;
					_insy = _ay + hg;
				}
				
				draw_set_color(COLORS._main_accent);
				draw_line_round(ui(8), _insy, _w - ui(8), _insy, ui(2));
			}
			
			if(text_drag == 1) {
				if(mouse_lrelease()) text_drag = 0;
				if(abs(_m[1] - text_drag_my) > hg/2) {
					text_drag = 2;
					array_remove(attributes.layer_order, text_dragging);
				}
			} else if(text_drag == 2) {
				if(mouse_lrelease()) {
					array_insert(attributes.layer_order, _insi, text_dragging);
					text_drag = 0;
				}
				
			}
		#endregion
		
		#region Drag Effect
			if(effect_drag == 2) {
				draw_set_color(COLORS._main_accent);
				draw_line_round(ui(24), _iney, _w - ui(8), _iney, ui(2));
			}
			
			if(effect_drag == 1) {
				if(mouse_lrelease()) effect_drag = 0;
				if(abs(_m[1] - effect_drag_my) > fhg/2) {
					effect_drag = 2;
					var ind = attributes.layer_order[effect_drag_par];
					array_remove(attributes.layer_effect[ind], effect_dragging);
				}
				
			} else if(effect_drag == 2) {
				if(mouse_lrelease()) {
					var ind = attributes.layer_order[effect_drag_par];
					array_insert(attributes.layer_effect[ind], _inei, effect_dragging);
					effect_drag = 0;
				}
				
			}
		#endregion
		
		text_h = _h;
		return _h;
	});
	
	input_display_list = [ 
		[ "Surface",  false ],  0,  
		[ "Matching", false ],  1,  
		new Inspector_Spacer(ui(4), true, false), texture_renderer, 
	];
	
	function createNewInput(i = array_length(inputs)) {
		
		////- Texture
		newInput(i+1, nodeValue_Color(    "Target", ca_black ));
		newInput(i+0, nodeValue_Surface(  "Texture"          )).setVisible(true, true);
		
			////- /Transform
		newInput(i+2, nodeValue_Vec2(     "Offset",   [0,0] )).setUnitSimple();
		newInput(i+3, nodeValue_Rotation( "Rotation",  0    ));
		newInput(i+4, nodeValue_Vec2(     "Scale",    [1,1] ));
		
		refreshDynamicDisplay();
		return inputs[i];
	} 
	
	input_display_dynamic = [ // 5
		[ "Texture",        false ],  1,  0,  
			[ "/Transform", false ],  2,  3,  4, 
	];
	
	setDynamicInput(5, true, VALUE_TYPE.surface);
	
	////- Nodes
	
	attributes.output_amount = 0;
	attributes.layer_order   = [];
	attributes.layer_effect  = [];
	layer_effect_map = {};
	
	temp_surface = array_create(2, noone);
	io_pool = [];
	
	effect_nodes = [];
	
	static add = function(_node) /*=>*/ {
		layer_effect_map[$ _node.node_id] = _node;
		_node.onTriggerRender = function() /*=>*/ {return triggerRender()};
		array_remove(project.allNodes, _node);
		array_push(effect_nodes, _node);
	}
	
	static getNodeList = function() /*=>*/ {return effect_nodes};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		if(dynamic_input_inspecting != noone) {
			var _amo = getInputAmount();
			dynamic_input_inspecting = min(dynamic_input_inspecting, _amo - 1);
			
			var _ind = input_fix_len + dynamic_input_inspecting * data_length;
			
			var _pos = getInputSingle(_ind+2);
			var  px  = _x + _pos[0] * _s;
			var  py  = _y + _pos[1] * _s;
			
			drawOverlayInput(inputs[_ind+2].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
			drawOverlayInput(inputs[_ind+3].drawOverlay(hover, active, px, py, _s, _mx, _my));
			
		}
	}
	
	static preGetInputs = function() {
		var _amo = getInputAmount();
		if(array_length(io_pool) < _amo) {
			for( var i = array_length(io_pool); i < _amo; i++ )
				io_pool[i] = nodeValue_Output($"Texture {i}", VALUE_TYPE.surface, noone);
		}
		
		var _olen = array_length(outputs);
		if(_olen < 1 + _amo) {
			for( var i = _olen; i <= _amo; i++ )
				outputs[i] = io_pool[i-1]
				
		} else if(_olen > 1 + _amo) 
			array_resize(outputs, 1 + _amo);
			
		attributes.output_amount = _amo;
		
		var _lamo = array_length(attributes.layer_order);
		if(_lamo > _amo) {
			for( var i = _amo; i < _lamo; i++ ) 
				array_remove(attributes.layer_order, i);
				
		} else if(_lamo < _amo) {
			for( var i = _lamo; i < _amo; i++ ) 
				array_insert(attributes.layer_order, 0, i);
		}
		
		var _lamo = array_length(attributes.layer_effect);
		for( var i = _lamo; i < _amo; i++ )
			attributes.layer_effect[i] = [];
			
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _thrs = _data[ 1];
			
			if(!is_surface(_surf)) return _outData;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			surface_clear(temp_surface[i]);
		}
		
		for( var i = 0, n = array_length(_outData); i < n; i++ ) 
			_outData[i] = surface_verify(_outData[i], _dim[0], _dim[1]);
		
		var _amo = getInputAmount();
		var _bg  = 0;
		
		surface_set_shader(temp_surface[1], sh_sample, true, BLEND.over);
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		shader_set(sh_texture_compose);
			shader_set_s( "original",  _surf );
			shader_set_2( "dimension", _dim  );
			
			shader_set_f( "threshold", _thrs );
		shader_reset();
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			
			var _text = _data[_ind+ 0];
			var _tarc = _data[_ind+ 1];
			
			var _offs = _data[_ind+ 2];
			var _rota = _data[_ind+ 3];
			var _scal = _data[_ind+ 4];
			
			if(!is_surface(_text)) continue;
			
			surface_set_shader([temp_surface[_bg], _outData[1+i]], sh_texture_compose, true, BLEND.over);
				shader_set_s( "texture",   _text );
				shader_set_c( "target",    _tarc );
				
				shader_set_2( "position",  _offs );
				shader_set_f( "rotation",  _rota );
				shader_set_2( "scale",     _scal );
				
				draw_surface(temp_surface[!_bg], 0, 0);
			surface_reset_shader();
			
			_bg = !_bg;
		}
		
		var _outSurf = _outData[0];
		surface_set_shader(temp_surface[_bg], noone, true, BLEND.over);
			draw_surface(temp_surface[!_bg], 0, 0);
		surface_reset_shader();
		_bg = !_bg;
		
		var _oamo = array_length(attributes.layer_order);
		for( var i = 0; i < _oamo; i++ ) {
			var _i = _oamo - i - 1;
			
			var _ind  = attributes.layer_order[_i];
			var _effs = attributes.layer_effect[_ind];
			
			var _layerSurf = _outData[_ind+1];
			
			for( var j = 0, m = array_length(_effs); j < m; j++ ) {
				var _eff = _effs[j];
				var _eno = layer_effect_map[$ _eff];
				if(!is(_eno, Node)) continue;
				
				var _inp = _eno.getInput(0, inputs[0]);
				var _otp = _eno.getOutput(0, inputs[0]);
				
				if(!is(_inp, NodeValue) || !is(_otp, NodeValue)) continue;
				
				if(_eno.input_mask_index >= 0) {
					var _minp = _eno.inputs[_eno.input_mask_index];
					var _umsk = bool(_eno.attributes[$ "effect_use_mask"]);
					
					if(_umsk) _minp.setValue(temp_surface[!_bg], false, CURRENT_FRAME, false);
					else      _minp.setValue(noone,              false, CURRENT_FRAME, false);
				}
				
				_inp.setValue(_layerSurf, false, CURRENT_FRAME, false);
				_eno.doUpdate();
				
				var _outS = _otp.getValue();
				if(!is_just_surface(_outS)) continue;
				
				_layerSurf = _outS
			}
			
			if(!is_just_surface(_layerSurf)) continue;
			
			surface_set_shader(temp_surface[_bg], sh_texture_compose_blend);
				shader_set_s( "surfaceBG", temp_surface[!_bg] );
				shader_set_s( "surfaceFG", _layerSurf         );
				
				draw_empty()
			surface_reset_shader();
			_bg = !_bg;
		}
			
		surface_set_shader(_outSurf, noone, true, BLEND.over);
			draw_surface(temp_surface[!_bg], 0, 0);
		surface_reset_shader();
		
		return _outData; 
	}
	
	////- Serialize
	
	static attributeSerialize = function( ) /*=>*/ { 
		var effNodes = [];
		for( var i = 0, n = array_length(effect_nodes); i < n; i++ ) 
			effNodes[i] = effect_nodes[i].serialize();
		
		return { effectNodes : effNodes };
	}
	
	static doAttributeDeserialize = function(attr) {
		if(has(attr, "effectNodes")) {
			effect_nodes = [];
			var effNodes = attr.effectNodes;
			
			for( var i = 0, n = array_length(effNodes); i < n; i++ ) {
				var _node = nodeLoad(effNodes[i], false, self);
				if(!is(_node, Node)) continue;
				
				_node.postDeserialize();
				_node.applyDeserialize();
				add(_node);
			}
		}
	}
	
	static preApplyDeserialize = function() {
		if(!has(attributes, "output_amount")) return;
		
		var _amo = attributes.output_amount;
		var _ind = 1;
		
		repeat(_amo) {
			var _pl = nodeValue_Output($"Texture {_ind-1}", VALUE_TYPE.surface, noone);
			array_push(io_pool, _pl);
			newOutput(_ind, _pl);
			_ind++;
		}
	}
	
}