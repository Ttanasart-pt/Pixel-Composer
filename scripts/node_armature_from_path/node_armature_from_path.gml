function Node_Armature_From_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature from Path";
	setDimension(96, 96);
	draw_padding = 8;
	
	////- =Path
	newInput(0, nodeValue_PathNode( "Path" )).setVisible(true, true);
	newInput(1, nodeValue_Int( "Bones",  4 ));
	
	////- =Armature
	
	// input 2
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 
		[ "Path", false ], 0, 1,  
	];
	
	__node_bone_attributes();
	
	bone_bbox = [0, 0, 1, 1, 1, 1];
	
	////- Preview
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _path = inputs[0].getValue();
		if(struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _bone = outputs[0].getValue();
		if(is(_bone, __Bone)) _bone.draw(attributes, false, _x, _y, _s, _mx, _my);
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _path = getInputData(0);
		var _samp = getInputData(1); _samp = max(2, _samp + 1);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is_path(_path)) return;
		
		var bone = new __Bone();
		bone.is_main = true;
		
		var ox, oy, nx, ny;
		var _p  = new __vec2P();
		var par = bone;
		
		for( var i = 0; i < _samp; i++ ) {
			var _prg = clamp(i / (_samp - 1), 0, .999);
			
			_p = _path.getPointRatio(_prg, 0, _p);
			nx = _p.x;
			ny = _p.y;
			
			if(i) {
				var _dir = point_direction(ox, oy, nx, ny);
				var _dis = point_distance(ox, oy, nx, ny);
				var _b   = new __Bone(par, _dis, _dir, _dir, _dis, self);
				
				_b.name = $"Bone {i}";
				par.addChild(_b);
				par = _b;
				
			} else {
				var _dir = point_direction(0, 0, nx, ny);
				var _dis = point_distance(0, 0, nx, ny);
				
				bone.direction = _dir;
				bone.distance  = _dis;
			}
			
			ox = nx;
			oy = ny;
		}
		
		bone.resetPose().setPosition();
		bone_bbox = bone.bbox();
		
		outputs[0].setValue(bone);
		
	}
	
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var bone = outputs[0].getValue();
		
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_from_path, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_from_path, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}