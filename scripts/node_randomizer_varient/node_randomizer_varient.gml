function Node_Randomizer_Varient(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Variant";
	always_pad = true;
	reactive_on_hover = true;
	setDimension(96, 64);
	
	newInput( 0, nodeValue_Text( "Track Ref.", "" ));
	
	newOutput( 0, nodeValue_Output( "Variant Index", VALUE_TYPE.integer,  0 ));
	newOutput( 1, nodeValue_Output( "Variant Amount", VALUE_TYPE.integer, 0 ));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	trackTarget   = undefined;
	
	trackIterate  = false;
	trackItrIndex = 0;
	trackItrAmo   = 0;
	
	insp1button = button(function(fr) /*=>*/ { 
		if(trackTarget == undefined || trackIterate) return;
		
		trackIterate  = true;
		trackItrIndex = 0;
		trackItrAmo   = array_length(trackTarget.varients);
		
	}).setTooltip(__txt("Iterate Variants")).setIcon(THEME.icon_random_varient).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static step = function() {
		if(!trackIterate) return;
		
		if(!RENDERING) {
			if(trackItrIndex >= trackItrAmo) {
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
		var _trks = project.randomizer.values;
		var _ref  = getInputData( 0);
		
		var _trkTarget = undefined;
		
		for( var i = 0, n = array_length(_trks); i < n; i++ ) {
			if(_trks[i].name == _ref) {
				_trkTarget = _trks[i];
				break;
			}
		}
		
		trackTarget = _trkTarget;
		if(_trkTarget == undefined) return;
		
		trackTarget.bindNode = self;
		var _vind = trackTarget.varIndex;
		var _vamo = array_length(trackTarget.varients);
		
		outputs[0].setValue(_vind);
		outputs[1].setValue(_vamo);
	}
	
	////- Draw
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		if(!is(trackTarget, Project_Randomizer_Track)) {
			draw_sprite_bbox_uniform(getMetaSpr(), 0, draw_bbox, c_white, 1, true);
			w = 96;
			h = 64;
			return;
		}
		
		var bbox = draw_bbox;
		var pad  = 6;
		
		var _xc  = xx + w / 2 * _s;
		var _yc  = yy + name_height * _s + (h - name_height) / 2 * _s;
		
		var _w   = w * _s - pad * _s;
		var _h   = h * _s - pad * _s;
		
		var _vind = trackTarget.varIndex;
		var _vamo = array_length(trackTarget.varients);
		
		var vs  = 12;
		var bs  = vs * _s;
		var col = max(1, floor(_w / bs));
		var row = ceil(_vamo / col);
		draggable = true;
		
		var cc = trackIterate? COLORS._main_value_positive : COLORS._main_icon;
		
		for( var i = 0; i < row; i++ ) {
			var rstr = i * col;
			var camo = min(_vamo - rstr, col);
			
			var rxs = _xc - (camo - 1) * bs / 2;
			var ryc = _yc - (row  - 1) * bs / 2 + i * bs;
			
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
					if(mouse_lclick(_focus)) trackTarget.setVarients(v);
				}
				
			}
		}
		
		h = name_height + row * vs + pad * 2;
	}
}
