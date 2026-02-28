function Node_Armature_Pose_Bone(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Pose Bone";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Bone( "Bone", function() /*=>*/ {return toggleBoneTarget()} ));
	
	////- =Pose
	newInput(5, nodeValue_Enum_Button( "Position Mode", 1, [ "Absolute", "Relative" ] ));
	newInput(2, nodeValue_Vec2(        "Position",     [0,0] ));
	
	newInput(6, nodeValue_Enum_Button( "Position Mode", 1, [ "Absolute", "Relative" ] ));
	newInput(3, nodeValue_Rotation(    "Rotation",      0 ));
	
	newInput(7, nodeValue_Enum_Button( "Position Mode", 1, [ "Absolute", "Relative" ] ));
	newInput(4, nodeValue_Float(        "Scale",        1 ));
	// inputs 8
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0, 
		[ "Target",   false ], 1,
		[ "Position", false ], 5, 2, 
		[ "Rotation", false ], 6, 3, 
		[ "Scale",    false ], 7, 4,  
	];
	
	__node_bone_attributes();
	
	boneHash  = "";
	bonePose  = new __Bone();
	bone_array = [];
	bone_bbox = [0, 0, 1, 1, 1, 1];
	
	anchor_selecting = noone;
	bone_targeting   = false;
	
	posing_sx = 0;
	posing_sy = 0;
	posing_mx = 0;
	posing_my = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		inputs[1].setSelecting(bone_targeting);
		
		if(bone_targeting) {
			var _b = getInputData(0);
			if(!is(_b, __Bone)) return true;
			
			var _hv = _b.draw(attributes, hover * BONE_EDIT.body, _x, _y, _s, _mx, _my, anchor_selecting);
			anchor_selecting = _hv;
			
			if(mouse_press(mb_left, active)) {
				if(_hv != noone) inputs[1].setValue(_hv[0].name);
				bone_targeting = false;
			}
			return true;
		}
		
		if(!is(bonePose, __Bone)) return;
		var _tar  = getInputData(1);
		var bPose = bonePose.findBoneByName(_tar);
		bonePose.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
	}
	
	////- Update
	
	static setBone = function() {
		var _b = getInputData(0);
		if(!is(_b, __Bone)) { boneHash = ""; return; }
		
		var _h = _b.getHash();
		if(boneHash == _h) return;
		
		boneHash  = _h;
		bonePose  = _b.clone().connect();
		bone_array = bonePose.toArray();
		bonePose.constrains = _b.constrains;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		setBone();
		
		var _b         = getInputData(0);
		var _b_target  = getInputData(1);
		
		var _posi_mode = getInputData(5);
		var _posi      = getInputData(2);
		
		var _rota_mode = getInputData(6);
		var _rota      = getInputData(3);
		
		var _scal_mode = getInputData(7);
		var _scal      = getInputData(4);
		
		bone_bbox = [ 0, 0, PROJ_SURF_W, PROJ_SURF_H, PROJ_SURF_W, PROJ_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		bonePose.resetPose().setPosition();
		outputs[0].setValue(bonePose);
		
		var bRaw  = _b.findBoneByName(_b_target);
		var bPose = bonePose.findBoneByName(_b_target);
		if(bPose == noone) return;
		
		if(_posi_mode == 0) {
			var _h = bPose.getHead();
			bPose.pose_posit[0] = _posi[0] - _h.x;
			bPose.pose_posit[1] = _posi[1] - _h.y;
			
		} else {
			bPose.pose_posit[0] = bRaw.pose_posit[0] + _posi[0];
			bPose.pose_posit[1] = bRaw.pose_posit[1] + _posi[1];
			
		}
		
		bPose.pose_rotate   = _rota_mode? bRaw.pose_rotate   + _rota    : _rota;
		bPose.pose_scale    = _scal_mode? bRaw.pose_scale    * _scal    : _scal;
		
		bonePose.setPose();
		bone_bbox = bonePose.bbox();
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(!is(bonePose, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_pose_bone, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_pose_bone, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bonePose.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}