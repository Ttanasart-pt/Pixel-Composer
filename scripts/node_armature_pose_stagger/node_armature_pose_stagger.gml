function Node_Armature_Pose_Stagger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Stagger";
	update_on_frame = true;
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =Stagger
	newInput(1, nodeValue_Bone( "Bone", function() /*=>*/ {return toggleBoneTarget()} ));
	newInput(2, nodeValue_Int(  "Amount",   3  ));
	newInput(6, nodeValue_Int(  "Frame",    1  ));
	
	////- =Rotation
	newInput(3, nodeValue_Rotation( "Rotation",  0 ));
	newInput(5, nodeValue_Slider(   "Stiffness", 0 ));
	newInput(7, nodeValue_Slider(   "Intertia",  1 ));
	
	////- =Scale
	newInput(4, nodeValue_Float( "Scale", 1 ));
	// inputs 8
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0,
		[ "Stagger",  false ], 1, 2, 6, 
		[ "Rotation", false ], 3, 5, 7, 
		[ "Scale",    false ], 4, 
	]
	
	__node_bone_attributes();
	
	boneHash  = "";
	bonePose  = new __Bone();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	bone_array  = [];
	
	anchor_selecting = noone;
	bone_targeting   = false;
	
	rotation_prev = 0;
	rotation_dh   = [];
	
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
	
	////- Preview
	
	static toggleBoneTarget = function() /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		inputs[1].setSelecting(bone_targeting);
		
		var _b = inputs[0].getValue();
		if(!is(bonePose, __Bone)) return;
		
		if(!bone_targeting) {
			var _tar = getInputData(1);
			bonePose.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
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
	
	static update = function(frame = CURRENT_FRAME) {
		setBone();
		
		var _b   = getInputData(0);
		var _tar = getInputData(1);
		var _amo = getInputData(2);
		var _frm = getInputData(6);
		
		var _rot  = getInputData(3);
		var _stif = getInputData(5); _stif = 1 - _stif;
		var _iner = getInputData(7);
		
		var _sca  = getInputData(4);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		if(IS_FIRST_FRAME) bonePose.resetPose().setPosition();
		
		rotation_dh = array_verify(rotation_dh, TOTAL_FRAMES);
		outputs[0].setValue(bonePose);
		
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
			
			// if(IS_FIRST_FRAME) {
				bPose.pose_posit[0] = bRaw.pose_posit[0];
				bPose.pose_posit[1] = bRaw.pose_posit[1];
				bPose.pose_rotate   = bRaw.pose_rotate;
			// }
			
			bPose.pose_scale    = bRaw.pose_scale;
		}
		
		var _bArr = [ bTarg ];
		if(IS_FIRST_FRAME) {
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
				
				_rr *= _stif;
				_sx *= _sca;
			} 
			
		} else {
			var _sx  = _sca;
			var _dr  = _rot;
			var _inf = 1;
			var _itr = 0;
			array_safe_set(rotation_dh, CURRENT_FRAME, _dr);
			
			repeat(_amo) {
				var _cArr = [];
				
				for( var i = 0, n = array_length(_bArr); i < n; i++ ) {
					var b  = _bArr[i];
					var rr = array_safe_get(rotation_dh, CURRENT_FRAME - _itr * _frm, 0);
					var targRot = b.pose_rotate + rr * _inf;
					
					b.pose_rotate = lerp(b.pose_rotate, targRot, _iner);
					b.pose_scale  *= _sx;
					
					array_append(_cArr, b.childs);
				}
				
				if(array_empty(_cArr)) break;
				_bArr = _cArr;
				_inf *= _stif;
				_sx  *= _sca;
				
				_itr++;
			}
			
		}
		
		rotation_prev = _rot;
		
		//////
		
		bonePose.setPose();
		bone_bbox = bonePose.bbox();
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static postApplyDeserialize = function() {
		setBone();
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
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

