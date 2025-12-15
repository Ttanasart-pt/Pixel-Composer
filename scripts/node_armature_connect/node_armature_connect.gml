function Node_Armature_Connect(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Connect";
	setDimension(96, 96);
	draw_padding = 8;
	
	////- =Base Armature
	newInput(0, nodeValue_Armature( "Base Armature"   )).setVisible(true, true);
	newInput(2, nodeValue_Bone(     "Base Parent",  function() /*=>*/ {return toggleBoneTarget()} ));
	newInput(3, nodeValue_Bool(     "Connect",  true  ));
	newInput(4, nodeValue_Vec2(     "Offset",   [0,0] )).setUnitSimple();
	
	////- =Sub Armature
	newInput(1, nodeValue_Armature( "Sub Armature" )).setVisible(true, true);
	newInput(5, nodeValue_Text(     "Suffix"       )).setDisplay(VALUE_DISPLAY.text_box);
	// input 6
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 
		[ "Base Armature", false ], 0, 2, 3, 4, 
		[ "Sub Armature",  false ], 1, 5, 
	];
	
	__node_bone_attributes();
	
	bone = noone;
	bone_bbox  = [0, 0, 1, 1, 1, 1];
	bone_array  = [];
	
	anchor_selecting = noone;
	bone_targeting   = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _arma = getInputData(5);
		var _par  = getInputData(7);
		var _con  = getInputData(8);
		var _typ  = getInputData(1);
		
		if(bone_targeting) {
			if(!is(_arma, __Bone)) return true;
			
			var _hv = _arma.draw(attributes, hover * BONE_EDIT.body, _x, _y, _s, _mx, _my, anchor_selecting, _tar);
			anchor_selecting = _hv;
			
			if(mouse_press(mb_left, active)) {
				if(_hv != noone) inputs[7].setValue(_hv[0].name);
				bone_targeting = false;
			}
			return true;
		}
		
		var ox = _x;
		var oy = _y;
		
		if(!is(_arma, __Bone)) _con = false;
		else {
			var pBone = bone.findBoneByName(_par);
			if(pBone != noone) {
				var _p = pBone.getTail();
				ox = _x + _p.x * _s;
				oy = _y + _p.y * _s;
			}
		}
		
		if( is( bone, __Bone)) bone.draw(attributes, false, _x, _y, _s, _mx, _my);
		
		if(!_con)     InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, ox, oy, _s, _mx, _my, _snx, _sny));
		if(_typ == 1) InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, ox, oy, _s, _mx, _my, _snx, _sny));
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _arma = getInputData(0);
		var _par  = getInputData(2);
		var _con  = getInputData(3);
		var _off  = getInputData(4);
		
		var _sarm = getInputData(1);
		var _suf  = getInputData(5);
		
		inputs[4].setVisible(!_con);
		
		bone_bbox = [ 0, 0, DEF_SURF_W, DEF_SURF_H, DEF_SURF_W, DEF_SURF_H ];
		if(!is(_arma, __Bone)) return;
		if(!is(_sarm, __Bone)) return;
		
		var parBone = bone.findBoneByName(_par);
		if(parBone == noone) return;
		
		bone = _arma.clone();
		bone.resetPose().setPosition();
		
		var _h = parBone.getHead();
		var _t = parBone.getTail();
		
		if(_con) {
			_ori[0] = _t.x;
			_ori[1] = _t.y;
			
			_tai[0] = _tai[0] + _t.x;
			_tai[1] = _tai[1] + _t.y;
			
		} else {
			_ori[0] = _ori[0] + _t.x - _h.x;
			_ori[1] = _ori[1] + _t.y - _h.y;
			
			_tai[0] = _tai[0] + _t.x - _h.x;
			_tai[1] = _tai[1] + _t.y - _h.y;
		}
		
		var _oriDis = point_distance(  0, 0, _ori[0], _ori[1] );
		var _oriDir = point_direction( 0, 0, _ori[0], _ori[1] );
		
		var _bneDis = _typ == 0? _dis : point_distance(  _ori[0], _ori[1], _tai[0], _tai[1] );
		var _bneDir = _typ == 0? _dir : point_direction( _ori[0], _ori[1], _tai[0], _tai[1] );
		
		var _b = new __Bone(parBone, _oriDis, _oriDir, _bneDir, _bneDis, self);
		parBone.addChild(_b);
		
		_b.name          = _nam;
		_b.parent_anchor = _con;
		
		bone.resetPose().setPosition();
		bone_bbox = bone.bbox();
		bone_array = bone.toArray();
		
		outputs[0].setValue(bone);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_bone, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_bone, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}