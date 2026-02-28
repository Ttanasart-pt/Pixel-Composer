function Node_Armature_Bone(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Bone";
	setDimension(96, 96);
	draw_padding = 8;
	dimension_index = -1;
	
	////- =Parent
	newInput(5, nodeValue_Armature()).setVisible(true, true);
	newInput(7, nodeValue_Bone( "Parent",  function() /*=>*/ {return toggleBoneTarget()} ));
	newInput(8, nodeValue_Bool( "Connect", true ));
	
	////- =Bone
	newInput(6, nodeValue_Text(     "Name",      "Bone" )).setDisplay(VALUE_DISPLAY.text_box);
	newInput(0, nodeValue_Vec2(     "Origin",    [0,0]  )).setUnitSimple();
	newInput(1, nodeValue_EButton(  "Type",       0, [ "Polar", "Two Points" ] ));
	newInput(2, nodeValue_Float(    "Length",     4     ));
	newInput(3, nodeValue_Rotation( "Direction",  0     ));
	newInput(4, nodeValue_Vec2(     "Tail",      [0,0]  )).setUnitSimple();
	// input 9
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, noone));
	
	input_display_list = [ 
		[ "Parent", false ], 5, 7, 8, 
		[ "Bone",   false ], 6, 0, 1, 2, 3, 4, 
	];
	
	__node_bone_attributes();
	
	bone = noone;
	bone_bbox  = [0, 0, 1, 1, 1, 1];
	bone_array  = [];
	
	anchor_selecting = noone;
	bone_targeting   = 0;
	
	////- Preview
	
	static toggleBoneTarget = function(i) /*=>*/ { bone_targeting = !bone_targeting; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
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
		
		if(!_con)     InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, ox, oy, _s, _mx, _my));
		if(_typ == 1) InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, ox, oy, _s, _mx, _my));
	}
	
	////- Update
	
	static update = function(frame = CURRENT_FRAME) {
		var _arma = getInputData(5);
		var _par  = getInputData(7);
		var _con  = getInputData(8);
		
		var _nam = getInputData(6);
		var _ori = getInputData(0);
		var _typ = getInputData(1);
		
		var _dis = getInputData(2);
		var _dir = getInputData(3);
		var _tai = getInputData(4);
		
		inputs[2].setVisible(_typ == 0);
		inputs[3].setVisible(_typ == 0);
		
		inputs[4].setVisible(_typ == 1);
		
		bone_bbox = [ 0, 0, PROJ_SURF_W, PROJ_SURF_H, PROJ_SURF_W, PROJ_SURF_H ];
		
		var parBone = noone;
		
		if(is(_arma, __Bone)) {
			bone    = _arma.clone();
			bone.resetPose().setPosition();
			
			inputs[0].setVisible(!_con);
			
			parBone = bone.findBoneByName(_par);
			if(parBone == noone) return;
			
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
			
		} else {
			bone    = new __Bone();
			bone.is_main = true;
			
			inputs[0].setVisible(true);
			
			parBone = bone;
			_con    = false;
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