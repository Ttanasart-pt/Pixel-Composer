function Node_Randomizer_Varient(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Variant";
	always_pad = true;
	reactive_on_hover = true;
	setDimension(96, 48);
	
	////- =Track
	newInput( 0, nodeValue_Text( "Track Ref.", "" ));
	newInput( 1, nodeValue_Int(  "Index",       0 ));
	// 2
	
	newOutput( 0, nodeValue_Output( "Variant Index",  VALUE_TYPE.integer, 0  ));
	newOutput( 1, nodeValue_Output( "Variant Amount", VALUE_TYPE.integer, 0  )).setVisible(false);
	newOutput( 2, nodeValue_Output( "Variants",       VALUE_TYPE.struct,  [] )).setVisible(false);
	
	input_display_list  = [ 
		[ "Track",   false ],  0, 
		[ "Combine", false ],  
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Struct( "Varient" )).setVisible(true, true);
		
		postCreateNewInput(index);
		refreshDynamicDisplay();
		array_push(input_display_list, index);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.struct);
	
	////- Nodes
	
	trackTarget   = undefined;
	
	trackIterate  = false;
	trackItrIndex = 0;
	
	trackItrAmo   = 0;
	track_amount  = 0;
	
	varient_array  = undefined;
	varient_amount = 0;
	varient_index  = 0;
	
	insp1button = button(function(fr) /*=>*/ { 
		if(trackIterate) return;
		
		track_amount   = trackTarget   == undefined? 0 : array_length(trackTarget.varients);
		varient_amount = varient_array == undefined? 0 : array_length(varient_array);
		
		trackItrAmo   = track_amount + varient_amount;
		if(trackItrAmo <= 0) return;
		                
		trackIterate  = true;
		trackItrIndex = 0;
		
	}).setTooltip(__txt("Iterate Variants")).setIcon(THEME.icon_random_varient).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static setTrackMulti = function(_ind) {
		varient_index = _ind;
		var _varTrk = array_safe_get(varient_array, _ind, noone);
		if(_varTrk == noone) return;
		
		for( var i = 0, n = array_length(_varTrk); i < n; i++ ) {
			var _var = _varTrk[i];
			
			var _trk = _var[0];
			var _tid = _var[1];
			
			if(is(_trk, Project_Randomizer_Section))
				_trk.setVarients(_tid);
		}
	}
	
	static step = function() {
		if(!trackIterate) return;
		
		if(!RENDERING) {
			if(trackItrIndex >= trackItrAmo) {
				trackIterate = false;
				return;
			}
			
			if(trackItrIndex < track_amount)
				 trackTarget.setVarients(trackItrIndex);
			else setTrackMulti(trackItrIndex - track_amount);
				
			trackItrIndex++;
			
			RenderAll();
			exportAll();
		}
	}
	
	static update = function() {
		var _trks     = project.randomizer.values;
		var _ref      = getInputData( 0);
		
		if(_ref != "" && !renamedManual) setDisplayName(_ref, false, false);
		
		#region get track
			var _trkTarget = undefined;
			
			for( var i = 0, n = array_length(_trks); i < n; i++ ) {
				if(is(_trks[i], Project_Randomizer_Section) && _trks[i].name == _ref) {
					_trkTarget = _trks[i];
					break;
				}
			}
			
			trackTarget = _trkTarget;
			if(is(trackTarget, Project_Randomizer_Section)) {
				trackTarget.bindNode = self;
				
				var _vind = trackTarget.varIndex;
				var _vamo = array_length(trackTarget.varients);
				var _vars = array_create(_vamo);
				
				for( var i = 0; i < _vamo; i++ )
					_vars[i] = [trackTarget, i];
				
				outputs[0].setValue(_vind);
				outputs[1].setValue(_vamo);
				outputs[2].setValue(_vars);
			}
		#endregion
		
		#region track combine
			varient_array = undefined;
			var _amo      = getInputAmount();
			
			if(_amo > 0) {
				var _comTrk = [];
				var _comAmo = [];
				
				for( var i = 0; i < _amo; i++ ) {
					var _tracks = getInputData(input_fix_len + i);
					_comTrk[i] = _tracks;
					_comAmo[i] = array_safe_length(_tracks);
				}
				
				var _comb = cartesian_product(_comAmo);
				varient_array = array_create(array_length(_comb));
				
				for( var i = 0, n = array_length(_comb); i < n; i++ ) {
					var _com    = _comb[i];
					var _mixTrk = [];
					
					for( var j = 0, m = array_length(_com); j < m; j++ ) {
						var _tt = _com[j];
						array_push(_mixTrk, _comTrk[j][_tt]);
					}
					
					varient_array[i] = _mixTrk;
				}
				
				outputs[0].setValue(varient_index);
				outputs[1].setValue(array_length(varient_array));
				outputs[2].setValue(varient_array);
			}
		#endregion
	}
	
	static getNodeDimension = function() {
		var _track_amount   = trackTarget   == undefined? 0 : array_length(trackTarget.varients);
		var _varient_amount = varient_array == undefined? 0 : array_length(varient_array);
		
		var _trackItrAmo   = _track_amount + _varient_amount;
		node_dimension_text = string(_trackItrAmo);
		
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var pad  = 6;
		
		var hh = name_height + pad * 2;
		var vs  = 12;
		var bs  = vs * _s;
		
		var _w   = w * _s - pad * _s;
		var _h   = h * _s - pad * _s;
			
		var _xc  = xx + w / 2 * _s;
		var  y0  = yy + name_height + pad * _s + bs;
		
		draggable = true;
		var cc = trackIterate? COLORS._main_value_positive : COLORS._main_icon;
		
		if(is(trackTarget, Project_Randomizer_Track)) {
			var _vind = trackTarget.varIndex;
			var _vamo = array_length(trackTarget.varients);
			
			var col = max(1, floor(_w / bs));
			var row = ceil(_vamo / col);
			
			for( var i = 0; i < row; i++ ) {
				var rstr = i * col;
				var camo = min(_vamo - rstr, col);
				
				var rxs = _xc - (camo - 1) * bs / 2;
				var ryc =  y0 + i * bs;
				
				for( var j = 0; j < camo; j++ ) {
					var v   = i * col + j;
					var rxc = rxs + j * bs;
					
					var vx = rxc - bs / 2;
					var vy = ryc - bs / 2;
					var vh = _hover && point_in_rectangle(_mx, _my, vx, vy, vx + bs, vy + bs);
					
					var vss = bs - 4*_s;
					var vx0 = vx + 2*_s;
					var vy0 = vy + 2*_s;
					
					if(v == _vind)
						draw_sprite_stretched_ext(THEME.palette_mask, 1, vx0, vy0, vss, vss, cc, 1);
					draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, vx0, vy0, vss, vss, cc, .75);
					
					if(vh) {
						draggable = false;
						draw_sprite_stretched_add(THEME.palette_mask_outline, 1, vx0, vy0, vss, vss, cc, 1);
						if(v != _vind && mouse_lclick(_focus)) trackTarget.setVarients(v);
					}
				
					if(trackTarget.preview_index == v) {
						draw_sprite_stretched_ext(THEME.palette_mask, 1, vx0, vy0, vss, vss, COLORS._main_accent, 1);
						trackTarget.preview_index = undefined;	
					}
				}
			}
			
			y0 += row * bs;
			hh += row * vs;
		}
		
		if(is_array(varient_array)) {
			var _vind = varient_index;
			var _vamo = array_length(varient_array);
			
			var col = max(1, floor(_w / bs));
			var row = ceil(_vamo / col);
			
			for( var i = 0; i < row; i++ ) {
				var rstr = i * col;
				var camo = min(_vamo - rstr, col);
				
				var rxs = _xc - (camo - 1) * bs / 2;
				var ryc =  y0 + i * bs;
				
				for( var j = 0; j < camo; j++ ) {
					var v   = i * col + j;
					var rxc = rxs + j * bs;
					
					var vx = rxc - bs / 2;
					var vy = ryc - bs / 2;
					var vh = _hover && point_in_rectangle(_mx, _my, vx, vy, vx + bs, vy + bs);
					
					var vss = bs - 4*_s;
					var vx0 = vx + 2*_s;
					var vy0 = vy + 2*_s;
					
					if(v == _vind)
						draw_sprite_stretched_ext(THEME.palette_mask, 1, vx0, vy0, vss, vss, cc, 1);
						
					draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, vx0, vy0, vss, vss, cc, .75);
					
					if(vh) {
						draggable = false;
						
						var varr = varient_array[v];
						for( var k = 0, m = array_length(varr); k < m; k++ ) 
							varr[k][0].preview_index = varr[k][1];
							
						draw_sprite_stretched_add(THEME.palette_mask_outline, 1, vx0, vy0, vss, vss, cc, 1);
						if(v != _vind && mouse_lclick(_focus))
							setTrackMulti(v);
					}
					
				}
			}
			
			y0 += row * bs;
			hh += row * vs;
		}
		
		h = max(48, hh);
	}
}
