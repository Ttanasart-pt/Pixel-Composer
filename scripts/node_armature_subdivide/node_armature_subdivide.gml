function Node_Armature_Subdivide(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Subdivide";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Bone( "Bone", function() /*=>*/ {return toggleBoneTarget()} ));
	
	////- =Subdivide
	newInput(2, nodeValue_Int(  "Subdivision", 4  ));
	// inputs 3
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0, 
		["Target",    false], 1,
		["Subdivide", false], 2, 
	];
	
	__node_bone_attributes();
	
	bone      = new __Bone();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	bone_array  = [];
	
	bone_target = "";
	bone_subdiv = 1;
	anchor_selecting = noone;
	bone_targeting   = false;
	
	////- Preview
	
	static toggleBoneTarget = function() /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		inputs[1].setSelecting(bone_targeting);
		
		if(!is(bone, __Bone)) return;
		if(!bone_targeting) {
			var _tar = getInputData(1);
			bone.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
			return true;
		}
		
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		var _hv = _b.draw(attributes, hover * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
		anchor_selecting = _hv;
		
		if(mouse_press(mb_left, active)) {
			if(_hv != noone) inputs[1].setValue(_hv[0].name);
			bone_targeting = false;
		}
		
		return anchor_selecting != noone;
	}
	
	////- Update
	
	static bone_subdivide = function(_bone, _newBone) {
		var _sub = _bone.name == bone_target? bone_subdiv : 1;
		var bAng = _bone.angle;
		var bLen = _bone.length;
		var sLen =  bLen / _sub;
		var _par = _newBone;
		
		if(!_bone.is_main)
		for( var i = 0; i < _sub; i++ ) {
			var _b = new __Bone(_par, 0, 0, bAng, sLen, self);
			
			if(i == 0) {
				_b.distance      = _bone.distance;
				_b.direction     = _bone.direction;
				_b.parent_anchor = _bone.parent_anchor;
			}
			
			_b.name           = $"{_bone.name}.{i}";
			_b.apply_scale    = _bone.apply_scale;
			_b.apply_rotation = _bone.apply_rotation;
			
 			_par.addChild(_b);
			_par = _b;
		}
		
		for( var i = 0, n = array_length(_bone.childs); i < n; i++ ) {
			var _child = _bone.childs[i];
			bone_subdivide(_child, _par);
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _b      = getInputData(0);
		bone_target = getInputData(1);
		bone_subdiv = getInputData(2);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		bone = new __Bone(noone, 0, 0, 0, 0, self);
		bone.is_main = true;
		bone_subdivide(_b, bone);
		
		bone.resetPose().setPosition();
		bone_bbox = bone.bbox();
		bone_array  = bone.toArray();
		
		outputs[0].setValue(bone);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_subdivide, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_subdivide, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
			
	}
}