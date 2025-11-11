function Node_Armature_Mirror(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Mirror";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =IK
	newInput(3, nodeValue_Text( "Suffix", "" )).setDisplay(VALUE_DISPLAY.text_box);
	newInput(1, nodeValue_Bone( "Origin", function() /*=>*/ {return toggleBoneTarget(1)} ));
	
	////- =Axis
	newInput(4, nodeValue_Enum_Button( "Angle Mode", 0, [ "Bone", "Custom" ]   ));
	newInput(2, nodeValue_Bone(        "Axis",       function() /*=>*/ {return toggleBoneTarget(2)} ));
	newInput(5, nodeValue_Rotation(    "Angle",      0 ));
	// input 6
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0, 
		["Mirror", false], 3, 1, 
		["Axis", false], 4, 2, 5, 
	];
	
	__node_bone_attributes();
	
	bone      = new __Bone();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	bone_array  = [];
	
	bone_target = "";
	bone_subdiv = 1;
	anchor_selecting = noone;
	bone_targeting   = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = bone_targeting == i? 0 : i; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		inputs[1].setSelecting(bone_targeting == 1);
		inputs[2].setSelecting(bone_targeting == 2);
		
		if(!is(bone, __Bone)) return;
		
		if(bone_targeting == 0) {
			var _tar = getInputData(1);
			bone.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
			return true;
		}
		
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		var _hv = _b.draw(attributes, hover * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
		anchor_selecting = _hv;
		
		if(mouse_press(mb_left, active)) {
			if(_hv != noone) inputs[bone_targeting].setValue(_hv[0].name);
			bone_targeting = 0;
		}
		
		return anchor_selecting != noone;
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _b = getInputData(0);
		
		var _b_suff   = getInputData(3);
		var _b_origin = getInputData(1);
		
		var _a_mode = getInputData(4);
		var _b_axis = getInputData(2);
		var _angle  = getInputData(5);
		
		inputs[2].setVisible(_a_mode == 0);
		inputs[5].setVisible(_a_mode == 1);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		bone      = _b.clone();
		bone_array  = bone.toArray();
		
		bone.resetPose().setPosition();
		outputs[0].setValue(bone);
		
		var _orig = bone.findBoneByName(_b_origin);
		var _axis = bone.findBoneByName(_b_axis);
		if(_orig == noone) return;
		
		var _ang = 0;
		
		if(_a_mode == 0) {
			_ang = _orig.parent.angle;
			if(_axis != noone) _ang = _axis.angle;
			
		} else if(_a_mode == 1) {
			_ang = _angle;
		}
		
		var _mirrored = _orig.clone();
		var _mirArr   = _mirrored.toArray();
		
		for( var i = 0, n = array_length(_mirArr); i < n; i++ ) {
			var _bm   = _mirArr[i];
		    _bm.ID    = UUID_generate();
			_bm.name  = _bm.name + _b_suff;
			_bm.angle = _ang + angle_difference(_ang, _bm.angle);
		}
		
		_orig.parent.addChild(_mirrored);
		
		bone.resetPose().setPosition();
		bone_bbox = bone.bbox();
		
	}
	
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_mirror, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_mirror, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}