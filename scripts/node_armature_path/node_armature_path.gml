function Node_Armature_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Path";
	setDimension(96, 96);
	
	newInput(0, nodeValue_Armature())
		.setVisible(true, true)
		.rejectArray();
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	lines = [];
	
	current_length  = 0;
	boundary  = new BoundingBox();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	
	__node_bone_attributes();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
	}
	
	static getBoundary     = function() /*=>*/ {return boundary};
	static getLineCount    = function() /*=>*/ {return array_length(lines)};
	static getSegmentCount = function() /*=>*/ {return 1};
	static getLength       = function() /*=>*/ {return current_length};
	static getAccuLength   = function() /*=>*/ {return [ 0, current_length ]};
	
	static getPointDistance = function(_dist, _ind = 0, out = undefined) { return getPointRatio(_dist / current_length, _ind, out); }
	
	static getPointRatio = function(_rat, _ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _p0 = lines[_ind][0];
		var _p1 = lines[_ind][1];
		
		if(!is_array(_p0) || array_length(_p0) < 2) return out;
		if(!is_array(_p1) || array_length(_p1) < 2) return out;
		
		out.x = lerp(_p0[0], _p1[0], _rat);
		out.y = lerp(_p0[1], _p1[1], _rat);
		
		return out;
	}
	
	static update = function() {
		var _bone = getInputData(0);
		if(!is(_bone, __Bone)) return;
		
		lines = [];
		current_length = 0;
		
		var _bst = ds_stack_create();
		ds_stack_push(_bst, _bone);
		
		while(!ds_stack_empty(_bst)) {
			var bone = ds_stack_pop(_bst);
			if(bone.IKlength) continue;
			
			if(!bone.is_main) {
				var _p0  = bone.getHead();
				var _p1  = bone.getTail();
			
				array_push(lines, [ 
					[_p0.x, _p0.y, 1], 
					[_p1.x, _p1.y, 1], 
				]);
				
				current_length += point_distance(_p0.x, _p0.y, _p1.x, _p1.y);
			}
			
			for( var i = 0, n = array_length(bone.childs); i < n; i++ ) {
				var child_bone = bone.childs[i];
				ds_stack_push(_bst, child_bone);
			}
		}
		
		ds_stack_destroy(_bst);
		
		bone_bbox = _bone.bbox();
		outputs[0].setValue(self);
	}
	
	////- Draw
		
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var  bbox = draw_bbox;
		var _bone = getInputData(0);
		
		if(is(_bone, __Bone))  {
			var _ss = _s * .5;
			gpu_set_tex_filter(1);
			draw_sprite_ext(s_node_armature_pose_stagger, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
			gpu_set_tex_filter(0);
			
			_bone.drawThumbnail(_s, bbox, bone_bbox);
			
		} else {
			gpu_set_tex_filter(1);
			draw_sprite_bbox_uniform(s_node_armature_pose_stagger, 0, bbox);
			gpu_set_tex_filter(0);
		}
	}
	
}