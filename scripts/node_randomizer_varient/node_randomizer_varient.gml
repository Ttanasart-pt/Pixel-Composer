function Node_Randomizer_Varient(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Variant";
	always_pad = true;
	reactive_on_hover = true;
	setDimension(96, 48);
	
	////- =Track
	newInput( 0, nodeValue_Text( "Section Name", "" ));
	// 1
	
	newOutput( 0, nodeValue_Output( "Variant Index",  VALUE_TYPE.integer, 0  ));
	newOutput( 1, nodeValue_Output( "Variant Amount", VALUE_TYPE.integer, 0  )).setVisible(false);
	newOutput( 2, nodeValue_Output( "Variants",       VALUE_TYPE.struct,  [] )).setVisible(false);
	
	input_display_list  = [ 
		[ "Section",   false ],  0, 
	];
	
	////- Nodes
	
	trackTarget   = undefined;
	
	trackIterate  = false;
	trackItrIndex = 0;
	
	track_amount  = 0;
	
	insp1button = button(function(fr) /*=>*/ { 
		if(trackIterate) return;
		
		track_amount  = trackTarget   == undefined? 0 : array_length(trackTarget.varients);
		if(track_amount <= 0) return;
        
		trackIterate  = true;
		trackItrIndex = 0;
		Project_Randomizer_Varient_Reset(project);
		
	}).setTooltip(__txt("Iterate Variants")).setIcon(THEME.icon_random_varient).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static step = function() {
		if(!trackIterate) return;
		
		if(!RENDERING) {
			if(trackItrIndex >= track_amount) {
				trackIterate = false;
				return;
			}
			
			trackTarget.setVarients(trackItrIndex);
			trackItrIndex++;
			
			RenderAll();
			exportAll();
		}
	}
	
	static update = function() {
		var _trks     = project.randomizer.values;
		var _ref      = getInputData( 0);
		
		if(_ref != "" && !renamedManual) setDisplayName(_ref, false, false);
		
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
	}
	
	static getNodeDimension = function() {
		var _track_amount   = trackTarget   == undefined? 0 : array_length(trackTarget.varients);
		node_dimension_text = string(_track_amount);
		
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var pad  = 10;
		
		var hh = name_height + pad * 2;
		var vs  = 12;
		var bs  = vs * _s;
		
		var _w   = w * _s - pad * _s;
		var _h   = h * _s - pad * _s;
			
		var _xc  = xx + w / 2 * _s;
		var  y0  = yy + (name_height + pad * 1.5) * _s;
		
		draw_set_color(COLORS._main_icon_dark);
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, bbox.x0, bbox.y0, bbox.x1 - bbox.x0, bbox.y1 - bbox.y0, COLORS._main_icon);
		
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
						
						var _cnt = trackTarget.contents;
			    		var _ind = trackTarget.varients[v];
			    		var _amo = min(array_length(_cnt), array_length(_ind));
			    		
			    		for( var k = 0; k < _amo; k++ ) {
			    			var _tr = _cnt[k];
			    			var _in = _ind[k];
			    			
			    			_tr.varHigh = _in;
			    		}
					}
				
					if(trackTarget.varHigh == v) {
						draw_sprite_stretched_ext(THEME.palette_mask, 1, vx0, vy0, vss, vss, COLORS._main_accent, 1);
						trackTarget.varHigh = undefined;	
					}
				}
			}
			
			y0 += row * bs;
			hh += row * vs;
		}
		
		h = max(48, hh);
	}
}
