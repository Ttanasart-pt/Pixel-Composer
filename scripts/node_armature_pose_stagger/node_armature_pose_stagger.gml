function Node_Armature_Pose_Stagger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Stagger";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =Stagger
	bTarget = button(function() /*=>*/ {return toggleBoneTarget()}).setIcon(THEME.bone, 1, COLORS._main_icon).setTooltip("Select Bone");
	newInput(1, nodeValue_Text( "Target",   "" )).setDisplay(VALUE_DISPLAY.text_box).setSideButton(bTarget);
	newInput(2, nodeValue_Int(  "Amount",   3  ));
	
	////- =Rotation
	newInput(3, nodeValue_Rotation(    "Rotation",            0  ));
	newInput(6, nodeValue_Enum_Button( "Rotation Shift Mode", 0, [ "Add", "Multiply" ] ));
	newInput(5, nodeValue_Float(       "Rotation Shift",      0  ));
	
	////- =Scale
	newInput(4, nodeValue_Float( "Scale", 1 ));
	// inputs 7
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0,
		[ "Stagger",  false ], 1, 2, 
		[ "Rotation", false ], 3, 6, 5, 
		[ "Scale",    false ], 4, 
	]
	
	__node_bone_attributes();
	
	boneHash  = "";
	bonePose  = noone;
	bone_bbox = [0, 0, 1, 1, 1, 1];
	boneArray = [];
	anchor_selecting = noone;
	
	static setBone = function() {
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		bonePose  = _b.clone().connect();
		boneArray = bonePose.toArray();
	}
	
	////- Preview
	
	bone_targeting = false;
	
	static toggleBoneTarget = function() {
		bone_targeting = true;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = inputs[0].getValue();
		if(!is(bonePose, __Bone)) return;
		
		bTarget.icon_blend = bone_targeting? COLORS._main_value_positive : COLORS._main_icon;
		if(!bone_targeting) {
			var _tar = getInputData(1);
			bonePose.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
			return;
		}
		
		var _hv = bonePose.draw(attributes, hover * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
		anchor_selecting = _hv;
		
		if(mouse_press(mb_left, active)) {
			if(_hv != noone) inputs[1].setValue(_hv[0].name);
			bone_targeting = false;
		}
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _b   = getInputData(0);
		var _tar = getInputData(1);
		var _amo = getInputData(2);
		
		var _rot  = getInputData(3);
		var _rotM = getInputData(6);
		var _rotS = getInputData(5);
		
		var _sca  = getInputData(4);
		
		if(!is(_b, __Bone)) return;
		if(_tar == "") return;
		
		var _h = _b.getHash();
		if(boneHash != _h) { boneHash = _h; setBone(); }
		
		bonePose.resetPose().setPosition();
		bonePose.constrains = _b.constrains;
		
		//////
		
		var bTarg = bonePose.findBoneByName(_tar);
		if(bTarg == noone) return;
		
		var bArrRaw = _b.toArray();
		var bArrPos = bonePose.toArray();
		
		for( var i = 0, n = array_length(bArrPos); i < n; i++ ) {
			var bRaw  = bArrRaw[i];
			var bPose = bArrPos[i];
			var _id   = bPose.ID;
			
			bPose.angle         = bRaw.angle;
			bPose.length        = bRaw.length;
			bPose.direction     = bRaw.direction;
			bPose.distance      = bRaw.distance;
			
			bPose.pose_posit[0] = bRaw.pose_posit[0];
			bPose.pose_posit[1] = bRaw.pose_posit[1];
			bPose.pose_rotate   = bRaw.pose_rotate;
			bPose.pose_scale    = bRaw.pose_scale;
		}
		
		var _bArr = [ bTarg ];
		var _rr = _rot;
		var _sx = _sca;
		
		repeat(_amo) {
			var _cArr = [];
			
			for( var i = 0, n = array_length(_bArr); i < n; i++ ) {
				var b = _bArr[i];
				b.pose_rotate += _rr;
				b.pose_scale  *= _sx;
				
				array_append(_cArr, b.childs);
			}
			
			if(array_empty(_cArr)) break;
			_bArr = _cArr;
			
			     if(_rotM == 0) _rot += _rotS;
			else if(_rotM == 1) _rot *= _rotS;
			
			_rr += _rot;
			_sx  *= _sca;
		}
		
		//////
		
		bonePose.setPose();
		bone_bbox = bonePose.bbox();
		
		outputs[0].setValue(bonePose);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static postApplyDeserialize = function() {
		setBone();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(is(bonePose, __Bone))  {
			var _ss = _s * .5;
			gpu_set_tex_filter(1);
			draw_sprite_ext(s_node_armature_pose_stagger, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
			gpu_set_tex_filter(0);
			
			bonePose.drawThumbnail(_s, bbox, bone_bbox);
			
		} else {
			gpu_set_tex_filter(1);
			draw_sprite_bbox_uniform(s_node_armature_pose_stagger, 0, bbox);
			gpu_set_tex_filter(0);
		}
	}
}

