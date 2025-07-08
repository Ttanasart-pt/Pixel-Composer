function Node_Armature_IK(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature IK";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature()).setVisible(true, true);
	
	////- =IK
	
	newInput(3, nodeValue_Text( "Name", "IK handle" )).setDisplay(VALUE_DISPLAY.text_box);
	
	newInput(1, nodeValue_Bone( "Origin", function() /*=>*/ {return toggleBoneTarget(1)} ));
	newInput(2, nodeValue_Bone( "Target", function() /*=>*/ {return toggleBoneTarget(2)} ));
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 0, 
		["IK", false], 3, 1, 2, 
	];
	
	__node_bone_attributes();
	
	bone      = new __Bone();
	bone_bbox = [0, 0, 1, 1, 1, 1];
	bone_arr  = [];
	
	anchor_selecting = noone;
	bone_targeting   = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = bone_targeting == i? 0 : i; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[1].setSelecting(bone_targeting == 1);
		inputs[2].setSelecting(bone_targeting == 2);
		
		if(!is(bone, __Bone)) return;
		
		if(bone_targeting == 0) {
			var _tar = getInputData(1);
			bone.draw(attributes, false, _x, _y, _s, _mx, _my, noone, _tar);
			return;
		}
		
		var _b = getInputData(0);
		if(!is(_b, __Bone)) return;
		
		var _hv = _b.draw(attributes, hover * 0b100, _x, _y, _s, _mx, _my, anchor_selecting);
		anchor_selecting = _hv;
		
		if(mouse_press(mb_left, active)) {
			if(_hv != noone) inputs[bone_targeting].setValue(_hv[0].name);
			bone_targeting = 0;
		}
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _b = getInputData(0);
		
		var _b_name   = getInputData(3);
		var _b_origin = getInputData(1);
		var _b_target = getInputData(2);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_b, __Bone)) return;
		
		bone = _b.clone();
		bone.resetPose().setPosition();
		
		var _orig = bone.findBoneByName(_b_origin);
		var _targ = bone.findBoneByName(_b_target);
		if(_targ == noone || _orig == noone) return;
		
		var _bone  = _targ;
		var _reach = false;
		var _blen  = 0;
		
		while(_bone != noone) {
			_blen++;
			_bone = _bone.parent;
			
			if(_bone == _orig.parent) {
				_reach = true;
				break;
			}
		}
		
		var  p0  = _orig.parent.getHead();
		var  p1  = _targ.getTail();
		var _len = point_distance(  p0.x, p0.y, p1.x, p1.y );
		var _ang = point_direction( p0.x, p0.y, p1.x, p1.y );
		
		var IKbone = new __Bone(_orig.parent, _len, _ang, 0, 0, self);
		_orig.parent.addChild(IKbone);
		
		IKbone.IKlength   = _blen;
		IKbone.IKTarget   = _targ;
		IKbone.IKTargetID = _targ.ID;
		
		IKbone.name = _b_name;
		IKbone.parent_anchor = false;
		
		bone.resetPose().setPosition();
		bone_bbox = bone.bbox();
		bone_arr  = bone.toArray();
		
		outputs[0].setValue(bone);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_ik, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_ik, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}