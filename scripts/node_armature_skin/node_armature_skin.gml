function Node_Armature_Skin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Skin";
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Armature
	newInput( 0, nodeValue_Armature());
	
	////- =Skin
	newInput( 2, nodeValue_Float( "Thickness", 4 ));
	// 3
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",   false ],  1,
		[ "Armature", false ],  0, 
		[ "Skin",     false ],  2, 
	]
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index+3, nodeValue_Bool(     "Draw",    true     ));
		
		var inp = newInput(index+0, nodeValue_Range(    "Radius", [1,1]     ));
		newInput(index+4, nodeValue_Bool(     "Inherit Scale",     true     ));
		
		newInput(index+1, nodeValue_Gradient( "Color",  gra_white ));
		newInput(index+2, nodeValue_Surface(  "Texture"           )).setVisible(true, false);
		
		postCreateNewInput(index);
		return inp;
	} 
	
	setDynamicInput( 5, false );
	
	////- Bone
	
	boneMap     = {};
	bone_array  = [];
	bone_points = [];
	boneHash    = "";
	__node_bone_attributes();
	
	static setBone = function() {
		var _b = getInputData(0);
		if(!is(_b, __Bone)) { boneHash = ""; return; }
		
		var _h = _b.getHash();
		if(boneHash == _h) return;
		
		boneHash   = _h;
		bone_array = _b.toArray();
		
		var _inputs = [];
		array_copy(_inputs, 0, inputs, 0, input_fix_len);
		var _input_display_list = array_clone(input_display_list_raw, 1);
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var bone = bone_array[i];
			if(bone.is_main || bone.control) continue;
			
			var _inp = has(boneMap, bone.ID)? inputs[boneMap[$ bone.ID]] : createNewInput();
			var _ind = _inp.index;
			boneMap[$ bone.ID] = _ind;
			
			array_push(_input_display_list, [ bone.name, false, _ind+3 ]);
			array_append(_input_display_list, [ _ind+0, _ind+4, _ind+1, _ind+2 ]);
			
			for( var j = 0; j < data_length; j++ ) {
				var ind = _ind + j;
				inputs[ind].attributes.bone_id = bone.ID;
				array_push(_inputs, inputs[ind]);
			}
			
		}
		
		for( var i = 0, n = array_length(_inputs); i < n; i++ )
			_inputs[i].index = i;
		
		inputs = _inputs;
		input_display_list = _input_display_list;
		refreshNodeDisplay();
	}
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _b = inputs[ 0].getValue();
		var _t = inputs[ 2].getValue();
		if(!is(_b, __Bone)) return;
		
		draw_set_circle_precision(16);
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var _bne  = bone_array[i];
			if(_bne.is_main || _bne.control) continue;
			
			var _bhov = noone;
			
			if(has(boneMap, _bne.ID)) {
				var bhd = _bne.getHead();
				var bx  = _x + bhd.x * _s;
				var by  = _y + bhd.y * _s;
			
				var _indx  = boneMap[$ _bne.ID];
				var _inHov = false;
				
				for( var j = 0; j < data_length; j++ ) {
					var inp = inputs[_indx + j];
					_inHov |= PANEL_INSPECTOR.prop_hover == inp || PANEL_ANIMATION.value_hovering == inp;
				}
				if(_inHov) _bhov = [ _bne, 2 ];
				
				var _drw = inputs[_indx + 3].getValue();
				
				var _rad = inputs[_indx + 0].getValue();
				var _inh = inputs[_indx + 4].getValue();
				
				var _par = _bne.parent;
				var _bsc = _par.is_main || !_inh? 1 : (_par[$ "__drawThickness"] ?? 1);
				
				if(_drw) {
					var _rs  = _rad[0] * _bsc * _t * _s;
					draw_set_color(COLORS._main_accent);
					draw_circle(bx, by, _rs, true);
				}
			}
			
			_bne.drawBone(attributes, false, _x, _y, _s, _mx, _my, _bhov, noone, c_white, 1);
		}
	}
	
	static update = function() {
		#region data
			var _dim  = getInputData( 1);
			
			var _bone = getInputData( 0);
			
			var _thck = getInputData( 2);
			
			if(!is(_bone, __Bone)) return;
			var _outSurf = outputs[0].getValue();
		#endregion
		
		setBone();
		_bone.setPose();
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ )
			bone_array[i].__drawThickness = 1;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf, sh_armature_skin_render);
			
			for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
				var _bone = bone_array[i];
				
				if(_bone.is_main || _bone.control) continue;
				if(!has(boneMap, _bone.ID)) continue;
				
				var _par   = _bone.parent;
				var binps  = boneMap[$ _bone.ID];
				
				var bdrw   = getInputData(binps + 3);
				
				var bthk   = getInputData(binps + 0);
				var thkInh = getInputData(binps + 4);
				
				var bcol   = getInputData(binps + 1);
				var btex   = getInputData(binps + 2);
				
				if(!bdrw) continue;
				
				var useTex = is_surface(btex);
				
				var hd = _bone.getHead();
				var tl = _bone.getTail();
				
				var x0 = hd.x, y0 = hd.y;
				var x1 = tl.x, y1 = tl.y;
				
				var dis = point_distance( x0, y0, x1, y1);
				var dir = point_direction(x0, y0, x1, y1);
				
				var _parSca = _par.is_main || !thkInh? 1 : _par.__drawThickness;
				_bone.__drawThickness = _parSca * bthk[1];
				
				shader_set_gradient(bcol);
				
				var c0 = c_white;
				var c1 = c_white;
				
				var th0 = _parSca * bthk[0] * _thck;
				var th1 = _parSca * bthk[1] * _thck;
				
				var px0 = lengthdir_x(th0, dir + 90);
				var py0 = lengthdir_y(th0, dir + 90);
				
				var px1 = lengthdir_x(th1, dir + 90);
				var py1 = lengthdir_y(th1, dir + 90);
				
				var v0x = x0 + px0, v0y = y0 + py0;
				var v1x = x0 - px0, v1y = y0 - py0;
				var v2x = x1 + px1, v2y = y1 + py1;
				var v3x = x1 - px1, v3y = y1 - py1;
				
				draw_primitive_begin_texture(pr_trianglelist, useTex? surface_get_texture(btex) : -1);
				draw_vertex_texture_color(v0x, v0y, 0, 0, c0, 1);
				draw_vertex_texture_color(v1x, v1y, 1, 0, c0, 1);
				draw_vertex_texture_color(v2x, v2y, 0, 1, c1, 1);
				
				draw_vertex_texture_color(v1x, v1y, 1, 0, c0, 1);
				draw_vertex_texture_color(v2x, v2y, 0, 1, c1, 1);
				draw_vertex_texture_color(v3x, v3y, 1, 1, c1, 1);
				
				var _capRes = 8;
				for( var j = 0; j < _capRes; j++ ) {
					var a0 = dir + 90 + (j+0) / _capRes * 180;
					var a1 = dir + 90 + (j+1) / _capRes * 180;
				
					var x00 = x0 + lengthdir_x(th0, a0);
					var y00 = y0 + lengthdir_y(th0, a0);
				
					var x01 = x0 + lengthdir_x(th0, a1);
					var y01 = y0 + lengthdir_y(th0, a1);
				
					var u0 = .5 + lengthdir_x(.5, a0 - dir + 90);
					var v0 = .5 + lengthdir_y(.5, a0 - dir + 90);
					
					var u1 = .5 + lengthdir_x(.5, a1 - dir + 90);
					var v1 = .5 + lengthdir_y(.5, a1 - dir + 90);
					
					draw_vertex_texture_color(x0, y0, .5, .5, c0, 1);
					draw_vertex_texture_color(x00, y00, u0, v0, c0, 1);
					draw_vertex_texture_color(x01, y01, u1, v1, c0, 1);
				}
				
				for( var j = 0; j < _capRes; j++ ) {
					var a0 = dir + 90 - (j+0) / _capRes * 180;
					var a1 = dir + 90 - (j+1) / _capRes * 180;
					
					var x10 = x1 + lengthdir_x(th1, a0);
					var y10 = y1 + lengthdir_y(th1, a0);
				
					var x11 = x1 + lengthdir_x(th1, a1);
					var y11 = y1 + lengthdir_y(th1, a1);
				
					var u0 = .5 + lengthdir_x(.5, a0 - dir + 90);
					var v0 = .5 + lengthdir_y(.5, a0 - dir + 90);
					
					var u1 = .5 + lengthdir_x(.5, a1 - dir + 90);
					var v1 = .5 + lengthdir_y(.5, a1 - dir + 90);
					
					draw_vertex_texture_color(x1, y1, .5, .5, c1, 1);
					draw_vertex_texture_color(x10, y10, u0, v0, c1, 1);
					draw_vertex_texture_color(x11, y11, u1, v1, c1, 1);
				}
			
				draw_primitive_end();
			}
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
	
	////- Serialize
	
	static postApplyDeserialize = function() {
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var inp = inputs[i];
			var idx = inp.attributes[$ "bone_id"] ?? 0;
			
			if(inp.name == "Radius") boneMap[$ idx] = i;
		}
		
		setBone();
	}
	
}