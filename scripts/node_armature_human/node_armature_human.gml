function Node_Armature_Human(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Humanoid";
	
	////- =Transform
	newInput( 0, nodeValue_Vec2(  "Position", [.5,1] )).setUnitSimple();
	newInput( 1, nodeValue_Float( "Height",     .75  )).setUnitSimple();
	
	////- =Head
	newInput( 2, nodeValue_Slider(   "Size",  .2 )).setInternalName("head_size" );
	newInput( 3, nodeValue_Rotation( "Angle", 90 )).setInternalName("head_angle");
	
	////- =Torso
	newInput( 4, nodeValue_Slider(   "Length",     .4      )).setInternalName("torso_size"    );
	newInput( 5, nodeValue_Int(      "Segment",     1      )).setInternalName("torso_segments").setCurvable( 6, CURVE_DEF_01, "Lengths");
	
	////- =Arms
	newInput( 7, nodeValue_Slider(   "Length",     .4      )).setInternalName("arms_size"    );
	newInput( 8, nodeValue_Int(      "Segment",     2      )).setInternalName("arms_segments").setCurvable( 9, CURVE_DEF_01, "Lengths");
	newInput(10, nodeValue_RotRange( "Rest Angle", [90,90] )).setInternalName("arms_angle"   ).setCurvable(11, CURVE_DEF_01, "Over Limb");
	
		////- =/IK
	newInput(17, nodeValue_Bool( "Use IK",    false )).setInternalName("arms_ik_use");
	newInput(18, nodeValue_Int(  "IK Length", 0     )).setInternalName("arms_ik_len");
	
	////- =Legs
	newInput(12, nodeValue_Slider(   "Length",     .4      )).setInternalName("legs_size"    );
	newInput(13, nodeValue_Int(      "Segment",     2      )).setInternalName("legs_segments").setCurvable(14, CURVE_DEF_01, "Lengths");
	newInput(15, nodeValue_RotRange( "Rest Angle", [15,0]  )).setInternalName("legs_angle"   ).setCurvable(16, CURVE_DEF_01, "Over Limb");
	
		////- =/IK
	newInput(19, nodeValue_Bool( "Use IK",    false )).setInternalName("legs_ik_use");
	newInput(20, nodeValue_Int(  "IK Length", 0     )).setInternalName("legs_ik_len");
	
	// 21
	
	newOutput(0, nodeValue_Output("Armature", VALUE_TYPE.armature, new __Bone()));
	
	input_display_list = [ 
		[ "Transform",  false ],  0,  1, 
		[ "Head",       false ],  2,  3,  
		[ "Torso",      false ],  4,  5,  6, 
		
		[ "Arms",   false     ],  7,  8,  9, 10, 11, 
			[ "/IK", true, 17 ], 18, 
			
		[ "Legs",   false     ], 12, 13, 14, 15, 16, 
			[ "/IK", true, 19 ], 20, 
	];
	
	////- Nodes
	
	__node_bone_attributes();
	
	bone_bbox = [0, 0, 1, 1, 1, 1];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var hovering = false;
		drawOverlayInput(inputs[ 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		
		attributes.hovering = hover;
		attributes.focusing = active;
		
		var _bone = outputs[0].getValue();
		if(is(_bone, __Bone)) _bone.draw(attributes, false, _x, _y, _s, _mx, _my);
		
		return hovering;
	}
	
	static update = function() {
		#region data
			var _pos = inputs[ 0].getValue();
			var _hei = inputs[ 1].getValue();
			
			var _head_size   = inputs[ 2].getValue();
			var _head_angl   = inputs[ 3].getValue();
			
			var _tors_size   = inputs[ 4].getValue();
			var _tors_segm   = inputs[ 5].getValue(); _tors_segm = max(1, _tors_segm);
			var _tors_segc   = inputs[ 5].attributes.curved? new curveMap(inputs[ 6].getValue()) : undefined;
			
			var _arms_size   = inputs[ 7].getValue();
			var _arms_segm   = inputs[ 8].getValue(); _arms_segm = max(1, _arms_segm);
			var _arms_segc   = inputs[ 8].attributes.curved? new curveMap(inputs[ 9].getValue()) : undefined;
			var _arms_angl   = inputs[10].getValue();
			var _arms_angc   = inputs[10].attributes.curved? new curveMap(inputs[11].getValue()) : undefined;
			
			var _arms_ik_use = inputs[17].getValue();
			var _arms_ik_amo = inputs[18].getValue();
			
			var _legs_size   = inputs[12].getValue();
			var _legs_segm   = inputs[13].getValue(); _legs_segm = max(1, _legs_segm);
			var _legs_segc   = inputs[13].attributes.curved? new curveMap(inputs[14].getValue()) : undefined;
			var _legs_angl   = inputs[15].getValue();
			var _legs_angc   = inputs[15].attributes.curved? new curveMap(inputs[16].getValue()) : undefined;
			
			var _legs_ik_use = inputs[19].getValue();
			var _legs_ik_amo = inputs[20].getValue();
			
		#endregion
		
		#region positions
			var _head_len  = _hei * _head_size;
			var _tors_len  = _hei * _tors_size;
			var _arms_len  = _hei * _arms_size;
			var _legs_len  = _hei * _legs_size;
			
			//// ================ Torso ================
			var _tors_ori  = [0,-_tors_len];
			var _tors_end  = [0,0];
			var _tors_segs = [[_tors_ori[0], _tors_ori[1]]];
			
			var _tors_st   = 1 / _tors_segm;
			for( var i = 0; i < _tors_segm; i++ ) {
				var t0 = i * _tors_st;
				var t1 = t0 + _tors_st;
				
				if(_tors_segc) {
					t0 = _tors_segc.get(t0);
					t1 = _tors_segc.get(t1);
				}
				
				var tdel  = t1 - t0;
				var _segL = _tors_len * tdel;
				var _segA = -90;
				
				var _lastSeg = array_last(_tors_segs);
				var _nextSeg = [
					_lastSeg[0] + lengthdir_x(_segL, _segA),
					_lastSeg[1] + lengthdir_y(_segL, _segA),
				];
				
				array_push(_tors_segs, _nextSeg);
			}
			
			//// ================ Legs ================
			var _legs_segs = [[_tors_end[0], _tors_end[1]]];
			var _legs_st   = 1 / _legs_segm;
			var _legs_height = 0;
			
			for( var i = 0; i < _legs_segm; i++ ) {
				var t0 = i * _legs_st;
				var t1 = t0 + _legs_st;
				
				if(_legs_segc) {
					t0 = _legs_segc.get(t0);
					t1 = _legs_segc.get(t1);
				}
				
				var tdel  = t1 - t0;
				var _segL = _legs_len * tdel;
				var _segA = _legs_segm <= 1? _legs_angl[0] : lerp(_legs_angl[0], _legs_angl[1], i / (_legs_segm - 1));
				    _segA = -90 + _segA;
				
				var _lastSeg = array_last(_legs_segs);
				var _nextSeg = [
					_lastSeg[0] + lengthdir_x(_segL, _segA),
					_lastSeg[1] + lengthdir_y(_segL, _segA),
				];
				
				array_push(_legs_segs, _nextSeg);
				_legs_height = _nextSeg[1];
			}
			
			//// ================ Arms ================
			var _arms_segs = [[_tors_ori[0], _tors_ori[1]]];
			var _arms_st   = 1 / _arms_segm;
			
			for( var i = 0; i < _arms_segm; i++ ) {
				var t0 = i * _arms_st;
				var t1 = t0 + _arms_st;
				
				if(_arms_segc) {
					t0 = _arms_segc.get(t0);
					t1 = _arms_segc.get(t1);
				}
				
				var tdel  = t1 - t0;
				var _segL = _arms_len * tdel;
				var _segA = _arms_segm <= 1? _arms_angl[0] : lerp(_arms_angl[0], _arms_angl[1], i / (_arms_segm - 1));
				    _segA = -90 + _segA;
				
				var _lastSeg = array_last(_arms_segs);
				var _nextSeg = [
					_lastSeg[0] + lengthdir_x(_segL, _segA),
					_lastSeg[1] + lengthdir_y(_segL, _segA),
				];
				
				array_push(_arms_segs, _nextSeg);
			}
			
			_tors_ori[1] -= _legs_height;
			_tors_end[1] -= _legs_height;
			
			for( var i = 0, n = array_length(_tors_segs); i < n; i++ ) 
				_tors_segs[i][1] -= _legs_height;
				
			for( var i = 0, n = array_length(_legs_segs); i < n; i++ ) 
				_legs_segs[i][1] -= _legs_height;
				
			for( var i = 0, n = array_length(_arms_segs); i < n; i++ ) 
				_arms_segs[i][1] -= _legs_height;
		#endregion
		
		var _bone = new __Bone();
		_bone.name      = "main";
		_bone.is_main   = true;
		_bone.direction = point_direction( 0, 0, _pos[0], _pos[1] );
		_bone.distance  = point_distance(  0, 0, _pos[0], _pos[1] );
		
		#region //// ================ Torso ================
			var _bone_par   = _bone;
			var _tors_bones = [];
			
			for( var i = 0, n = array_length(_tors_segs) - 1; i < n; i++ ) {
				var s0 = _tors_segs[i];
				var s1 = _tors_segs[i+1];
				
				if(i == 0) {
					var _tors_part = new __Bone(_bone, 
						point_distance( 0, 0, s0[0], s0[1]), 
						point_direction(0, 0, s0[0], s0[1]), 
						
						point_direction(s0[0], s0[1], s1[0], s1[1]), 
						point_distance( s0[0], s0[1], s1[0], s1[1]),
						self
					);
					
					_tors_part.parent_anchor = false;
					_tors_part.name = $"torso_main";
					
				} else {
					var _tors_part = new __Bone(_bone, 
						0, 
						0, 
						
						point_direction(s0[0], s0[1], s1[0], s1[1]), 
						point_distance( s0[0], s0[1], s1[0], s1[1]),
						self
					);
					
					_tors_part.name = $"torso_{i}";
				}
				
				_bone_par.addChild(_tors_part);
				array_push(_tors_bones, _tors_part);
				_bone_par = _tors_part;
			}
		#endregion
		
		#region //// ================ Head ================
			var s0 = array_first(_tors_segs);
			
			var _head = new __Bone(_bone, 
				point_distance( 0, 0, s0[0], s0[1]), 
				point_direction(0, 0, s0[0], s0[1]), 
				
				_head_angl, 
				_head_len,
				
				self
			);
			
			_head.parent_anchor = false;
			_head.name = $"head";
			
			_bone.addChild(_head);
		#endregion
		
		#region //// ================ Legs ================
			var _bone_par = array_last(_tors_bones);
			var _legs_r_bones = [];
			var _legs_l_bones = [];
			
			for( var i = 0, n = array_length(_legs_segs) - 1; i < n; i++ ) {
				var s0 = _legs_segs[i];
				var s1 = _legs_segs[i+1];
				
				var _legs_part = new __Bone(_bone, 0, 0, 
					point_direction(s0[0], s0[1], s1[0], s1[1]), 
					point_distance( s0[0], s0[1], s1[0], s1[1]),
					self
				);
				
				if(i == 0) _legs_part.name = $"legs_r_main";
				else       _legs_part.name = $"legs_r_{i}";
				
				_bone_par.addChild(_legs_part);
				_bone_par = _legs_part;
				
				array_push(_legs_r_bones, _legs_part);
			}
			
			if(_legs_ik_use) {
				var _blen = _legs_ik_amo? _legs_ik_amo : _legs_segm;
				
				var _targ = array_last(_legs_r_bones);
				var _orig = _targ;
				
				repeat(_blen) { if(!_orig.parent) break; _orig = _orig.parent; }
					
				_orig.setPosition();
				_targ.setPosition();
				
				var  p0  = _orig.getHead();
				var  p1  = _targ.getTail();
				var _len = point_distance(  p0.x, p0.y, p1.x, p1.y );
				var _ang = point_direction( p0.x, p0.y, p1.x, p1.y );
				
				var IKbone = new __Bone(_orig, _len, _ang, 0, 0, self);
				_orig.addChild(IKbone);
				
				IKbone.direction  = _ang;
				IKbone.distance   = _len;
								
				IKbone.control    = true;
				IKbone.IKlength   = _blen;
				IKbone.IKTarget   = _targ;
				IKbone.IKTargetID = _targ.ID;
				
				IKbone.name = "legs_r_ik";
				IKbone.parent_anchor = false;
			}
			
			///////////////////////////////////////////////////////////////////////////////
			
			var _bone_par = array_last(_tors_bones);
			
			for( var i = 0, n = array_length(_legs_segs) - 1; i < n; i++ ) {
				var s0 = _legs_segs[i];
				var s1 = _legs_segs[i+1];
				
				var _legs_part = new __Bone(_bone, 0, 0, 
					point_direction(-s0[0], s0[1], -s1[0], s1[1]), 
					point_distance( -s0[0], s0[1], -s1[0], s1[1]),
					self
				);
				
				if(i == 0) _legs_part.name = $"legs_l_main";
				else       _legs_part.name = $"legs_l_{i}";
				
				_bone_par.addChild(_legs_part);
				_bone_par = _legs_part;
				
				array_push(_legs_l_bones, _legs_part);
			}
			
			if(_legs_ik_use) {
				var _blen = _legs_ik_amo? _legs_ik_amo : _legs_segm;
				
				var _targ = array_last(_legs_l_bones);
				var _orig = _targ;
				
				repeat(_blen) { if(!_orig.parent) break; _orig = _orig.parent; }
					
				_orig.setPosition();
				_targ.setPosition();
				
				var  p0  = _orig.getHead();
				var  p1  = _targ.getTail();
				var _len = point_distance(  p0.x, p0.y, p1.x, p1.y );
				var _ang = point_direction( p0.x, p0.y, p1.x, p1.y );
				
				var IKbone = new __Bone(_orig, _len, _ang, 0, 0, self);
				_orig.addChild(IKbone);
				
				IKbone.direction  = _ang;
				IKbone.distance   = _len;
								
				IKbone.control    = true;
				IKbone.IKlength   = _blen;
				IKbone.IKTarget   = _targ;
				IKbone.IKTargetID = _targ.ID;
				
				IKbone.name = "legs_l_ik";
				IKbone.parent_anchor = false;
			}
			
		#endregion
		
		#region //// ================ Arms ================
			var _bone_par = _bone;
			var _arms_r_bones = [];
			var _arms_l_bones = [];
			
			for( var i = 0, n = array_length(_arms_segs) - 1; i < n; i++ ) {
				var s0 = _arms_segs[i];
				var s1 = _arms_segs[i+1];
				
				if(i == 0) {
					var _arms_part = new __Bone(_bone, 
						point_distance( 0, 0, s0[0], s0[1]), 
						point_direction(0, 0, s0[0], s0[1]), 
						
						point_direction(s0[0], s0[1], s1[0], s1[1]), 
						point_distance( s0[0], s0[1], s1[0], s1[1]),
						self
					);
					
					_arms_part.parent_anchor = false;
					_arms_part.name = $"arms_r_main";
					
				} else {
					var _arms_part = new __Bone(_bone, 
						0, 
						0, 
						
						point_direction(s0[0], s0[1], s1[0], s1[1]), 
						point_distance( s0[0], s0[1], s1[0], s1[1]),
						self
					);
					
					_arms_part.name = $"arms_r_{i}";
				}
				
				_bone_par.addChild(_arms_part);
				_bone_par = _arms_part;
				
				array_push(_arms_r_bones, _arms_part);
			}
			
			if(_arms_ik_use) {
				var _blen = _arms_ik_amo? _arms_ik_amo : _arms_segm;
				
				var _targ = array_last(_arms_r_bones);
				var _orig = _targ;
				
				repeat(_blen) { if(!_orig.parent) break; _orig = _orig.parent; }
					
				_orig.setPosition();
				_targ.setPosition();
				
				var  p0  = _orig.getHead();
				var  p1  = _targ.getTail();
				var _len = point_distance(  p0.x, p0.y, p1.x, p1.y );
				var _ang = point_direction( p0.x, p0.y, p1.x, p1.y );
				
				var IKbone = new __Bone(_orig, _len, _ang, 0, 0, self);
				_orig.addChild(IKbone);
				
				IKbone.direction  = _ang;
				IKbone.distance   = _len;
								
				IKbone.control    = true;
				IKbone.IKlength   = _blen;
				IKbone.IKTarget   = _targ;
				IKbone.IKTargetID = _targ.ID;
				
				IKbone.name = "arms_r_ik";
				IKbone.parent_anchor = false;
			}
			
			///////////////////////////////////////////////////////////////////////////////
			
			var _bone_par = _bone;
			
			for( var i = 0, n = array_length(_arms_segs) - 1; i < n; i++ ) {
				var s0 = _arms_segs[i];
				var s1 = _arms_segs[i+1];
				
				if(i == 0) {
					var _arms_part = new __Bone(_bone, 
						point_distance( 0, 0, -s0[0], s0[1]), 
						point_direction(0, 0, -s0[0], s0[1]), 
						
						point_direction(-s0[0], s0[1], -s1[0], s1[1]), 
						point_distance( -s0[0], s0[1], -s1[0], s1[1]),
						self
					);
					
					_arms_part.parent_anchor = false;
					_arms_part.name = $"arms_l_main";
					
				} else {
					var _arms_part = new __Bone(_bone, 
						0, 
						0, 
						
						point_direction(-s0[0], s0[1], -s1[0], s1[1]), 
						point_distance( -s0[0], s0[1], -s1[0], s1[1]),
						self
					);
					
					_arms_part.name = $"arms_l_{i}";
				}
				
				_bone_par.addChild(_arms_part);
				_bone_par = _arms_part;
				
				array_push(_arms_l_bones, _arms_part);
			}
			
			if(_arms_ik_use) {
				var _blen = _arms_ik_amo? _arms_ik_amo : _arms_segm;
				
				var _targ = array_last(_arms_l_bones);
				var _orig = _targ;
				
				repeat(_blen) { if(!_orig.parent) break; _orig = _orig.parent; }
					
				_orig.setPosition();
				_targ.setPosition();
				
				var  p0  = _orig.getHead();
				var  p1  = _targ.getTail();
				var _len = point_distance(  p0.x, p0.y, p1.x, p1.y );
				var _ang = point_direction( p0.x, p0.y, p1.x, p1.y );
				
				var IKbone = new __Bone(_orig, _len, _ang, 0, 0, self);
				_orig.addChild(IKbone);
				
				IKbone.direction  = _ang;
				IKbone.distance   = _len;
								
				IKbone.control    = true;
				IKbone.IKlength   = _blen;
				IKbone.IKTarget   = _targ;
				IKbone.IKTargetID = _targ.ID;
				
				IKbone.name = "arms_l_ik";
				IKbone.parent_anchor = false;
			}
			
		#endregion
		
		_bone.setIDFromName();
		_bone.resetPose().setPosition();
		bone_bbox = _bone.bbox();
		
		outputs[ 0].setValue(_bone);
	}
	
	////- Draw
	
	static getPreviewBoundingBox = function() /*=>*/ {return new BBOX().fromPoints(bone_bbox[0], bone_bbox[1], bone_bbox[2], bone_bbox[3])};
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var bone = outputs[0].getValue();
		
		if(!is(bone, __Bone)) { draw_sprite_bbox_uniform(s_node_armature_from_path, 0, bbox, c_white, 1, true); return; }
		
		var _ss = _s * .5;
		draw_sprite_ext_filter(s_node_armature_from_path, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
		bone.drawThumbnail(_s, bbox, bone_bbox);
		
	}
}
