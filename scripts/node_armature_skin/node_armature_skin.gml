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
		[ "Output",   false ], 1, 
		[ "Armature", false ], 0, 
		[ "Skin",     false ], 2, 
	]
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		var _inpR = newInput(index+0, nodeValue_Range(    "Radius", [1,1]     ));
		var _inpC = newInput(index+1, nodeValue_Gradient( "Color",  gra_white ));
		var _inpT = newInput(index+2, nodeValue_Surface(  "Texture"           ));
		
		return [_inpR, _inpC, _inpT];
	} 
	setDynamicInput(3, false);
	
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
		var _inp;
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var bone = bone_array[i];
			if(bone.is_main || bone.control) continue;
			
			if(has(boneMap, bone.ID))
				_inp = boneMap[$ bone.ID];
			else
				_inp = createNewInput();
			boneMap[$ bone.ID] = _inp;
			
			array_push(_input_display_list, [ bone.name, false ]);
			for( var j = 0, m = array_length(_inp); j < m; j++ ) {
				
				_inp[j].attributes.bone_id = bone.ID;
				array_push(_input_display_list, array_length(_inputs));
				array_push(_inputs, _inp[j]);
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
			
			var bhd = _bne.getHead();
			var bx  = _x + bhd.x * _s;
			var by  = _y + bhd.y * _s;
			
			if(has(boneMap, _bne.ID)) {
				var _inps  = boneMap[$ _bne.ID];
				var _inHov = array_any(_inps, function(inp,i) /*=>*/ {return PANEL_INSPECTOR.prop_hover == inp});
				if(_inHov) _bhov = [ _bne, 2 ];
				
				var _par = _bne.parent;
				var _bsc = _par.is_main? 1 : (_par[$ "__drawThickness"] ?? 1);
				
				var _rad = _inps[0].getValue();
				var _rs  = _rad[0] * _bsc * _t * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_circle(bx, by, _rs, true);
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
		
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var _bone = bone_array[i];
			_bone.__drawThickness = 1;
		}
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_shader(_outSurf, sh_armature_skin_render);
			
			for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
				var _bone = bone_array[i];
				
				if(_bone.is_main || _bone.control) continue;
				if(!has(boneMap, _bone.ID)) continue;
				
				var _par = _bone.parent;
				
				var binps = boneMap[$ _bone.ID];
				var bthk = getInputData(binps[ 0].index);
				var bcol = getInputData(binps[ 1].index);
				var btex = getInputData(binps[ 2].index);
				
				var useTex = is_surface(btex);
				
				var hd = _bone.getHead();
				var tl = _bone.getTail();
				
				var x0 = hd.x, y0 = hd.y;
				var x1 = tl.x, y1 = tl.y;
				
				var dis = point_distance( x0, y0, x1, y1);
				var dir = point_direction(x0, y0, x1, y1);
				
				var _parSca = _par.is_main? 1 : _par.__drawThickness;
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
				
				if(!useTex) {
					var _capRes = 8;
					for( var j = 0; j < _capRes; j++ ) {
						var a0 = dir + 90 + (j+0) / _capRes * 180;
						var a1 = dir + 90 + (j+1) / _capRes * 180;
					
						draw_vertex_texture_color(x0, y0, 0, 0, c0, 1);
						draw_vertex_texture_color(x0 + lengthdir_x(th0, a0), y0 + lengthdir_y(th0, a0), 0, 0, c0, 1);
						draw_vertex_texture_color(x0 + lengthdir_x(th0, a1), y0 + lengthdir_y(th0, a1), 0, 0, c0, 1);
					}
					
					for( var j = 0; j < _capRes; j++ ) {
						var a0 = dir + 90 - (j+0) / _capRes * 180;
						var a1 = dir + 90 - (j+1) / _capRes * 180;
						
						draw_vertex_texture_color(x1, y1, 0, 1, c1, 1);
						draw_vertex_texture_color(x1 + lengthdir_x(th1, a0), y1 + lengthdir_y(th1, a0), 0, 1, c1, 1);
						draw_vertex_texture_color(x1 + lengthdir_x(th1, a1), y1 + lengthdir_y(th1, a1), 0, 1, c1, 1);
					}
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
			
			if(!has(boneMap, idx)) 
				boneMap[$ idx] = [];
			array_push(boneMap[$ idx], inp);
		}
		
		setBone();
	}
	
}