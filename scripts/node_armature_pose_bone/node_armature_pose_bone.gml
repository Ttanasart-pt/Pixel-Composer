function Node_Armature_Pose_Bone(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose Bone";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Bone( "Bone", function() /*=>*/ {return toggleBoneTarget()} ));
	
	////- =Pose
	newInput(2, nodeValue( "Pose", self, CONNECT_TYPE.input, VALUE_TYPE.float, [ 0, 0, 0, 1 ] )).setDisplay(VALUE_DISPLAY.transform);
	// inputs 3
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0, 
		["Target", false], 1,
		["Pose",   false], 2, 
	];
	
	__node_bone_attributes();
	
	bone      = new __Bone();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	bone_arr  = [];
	
	anchor_selecting = noone;
	bone_targeting   = false;
	
	posing_sx = 0;
	posing_sy = 0;
	posing_mx = 0;
	posing_my = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[1].setSelecting(bone_targeting);
		
		if(bone_targeting) {
			var _b = getInputData(0);
			if(!is(_b, __Bone)) return;
			
			var _hv = _b.draw(attributes, hover * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
			anchor_selecting = _hv;
			
			if(mouse_press(mb_left, active)) {
				if(_hv != noone) inputs[1].setValue(_hv[0].name);
				bone_targeting = false;
			}
			return;
		}
		
		if(!is(bone, __Bone)) return;
		var _tar  = getInputData(1);
		var bPose = bone.findBoneByName(_tar);
		bone.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
		
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _b        = getInputData(0);
		var _b_target = getInputData(1);
		var _pose     = getInputData(2);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		bone     = _b.clone();
		bone_arr = bone.toArray();
		
		bone.resetPose().setPosition();
		outputs[0].setValue(bone);
		
		var bRaw  = _b.findBoneByName(_b_target);
		var bPose = bone.findBoneByName(_b_target);
		if(bPose == noone) return;
		
		bPose.pose_posit[0] = bRaw.pose_posit[0] + _pose[TRANSFORM.pos_x];
		bPose.pose_posit[1] = bRaw.pose_posit[1] + _pose[TRANSFORM.pos_y];
		bPose.pose_rotate   = bRaw.pose_rotate   + _pose[TRANSFORM.rot];
		bPose.pose_scale    = bRaw.pose_scale    * _pose[TRANSFORM.sca_x];
		
		bone.setPose();
		bone_bbox = bone.bbox();
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_pose_bone, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_pose_bone, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}