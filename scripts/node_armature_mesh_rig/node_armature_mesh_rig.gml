#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Armature_Mesh_Rig",  "Pose",          "P");
		hotkeyTool("Node_Armature_Mesh_Rig",  "Weight Brush",  "B");
		hotkeyTool("Node_Armature_Mesh_Rig",  "Weight Eraser", "E");
	});
#endregion

function RiggedMeshedSurface() : dynaSurf() constructor {
	mesh    = noone;
	bone    = noone;
	boneMap = noone;
	rigMap  = {};
	
	static getSurface        = function() { return mesh == noone? noone : mesh.surface; }
	static getSurfacePreview = function() { return getSurface(); }
}

function Node_Armature_Mesh_Rig(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Mesh Rig";
	setDimension(96, 96);
	draw_padding = 8;
	
	newInput(0, nodeValue_Armature("Armature", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Mesh("Mesh", self, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Trigger("Autoweight", self ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Auto weight", UI : true, onClick: function() /*=>*/ {return AutoWeightPaint()} });
		
	newInput(3, nodeValue_Float("Auto Weight Radius", self, 8))
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Rigged Surface", self, VALUE_TYPE.dynaSurface, noone));
	
	bone_posed       = noone;
	bone_array       = [];
	rigdata          = noone;
	anchor_selecting = noone;
	bone_bbox        = undefined;
	preview_alpha    = .5;
	
	attributes.bonePoseData = {};
	attributes.rigBones     = noone;
	attributes.baked        = false;
	attributes.bakeData     = 0;
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	attributes.display_mesh_size = 2;
	
	tool_attribute.size = 48;
	tool_size_edit      = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { tool_attribute.size = max(1, round(val)); }).setFont(f_p3)
	tool_size           = [ "Size", tool_size_edit, "size", tool_attribute ];
	
	tool_attribute.weight = .5;
	tool_weight_edit      = new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { tool_attribute.weight = clamp(val, 0, 1); }).setFont(f_p3)
	tool_weight           = [ "Weight", tool_weight_edit, "weight", tool_attribute ];
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() /*=>*/ {return attributes.display_name},      new checkBox(function() /*=>*/ { attributes.display_name = !attributes.display_name; })]);
	array_push(attributeEditors, ["Display bone", function() /*=>*/ {return attributes.display_bone},      new scrollBox(__txts(["Octahedral", "Stick"]), function(i) /*=>*/ { attributes.display_bone = i; })]);
	array_push(attributeEditors, ["Vertex size",  function() /*=>*/ {return attributes.display_mesh_size}, textBox_Number(function(i) /*=>*/ { attributes.display_mesh_size = i; })]);
	
	tools_dynamic = [
		new NodeTool( "Pose",          THEME.bone_tool_pose      ),
	];
	
	tools_baked = [
		new NodeTool( "Pose",          THEME.bone_tool_pose      ),
		
		new NodeTool( "Weight Brush",  THEME.canvas_tools_pencil )
			.setSetting(tool_size)
			.setSetting(tool_weight),
			
		new NodeTool( "Weight Eraser", THEME.canvas_tools_eraser )
			.setSetting(tool_size)
			.setSetting(tool_weight),
	];
	
	tools = tools_dynamic;
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var _b = inputs[0].getValue();
		if(_b == noone) return 0;
		
		var amo = _b.childCount();
		var _hh = ui(28);
		var _bh = ui(16) + amo * _hh;
		var ty  = _y;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, ty, _w, _bh, COLORS.node_composite_bg_blend, 1);
		ty += ui(8);
		
		var hovering = noone;
		var _bst = ds_stack_create();
		ds_stack_push(_bst, [ _b, _x, _w ]);
		
		anchor_selecting = noone;
		
		while(!ds_stack_empty(_bst)) {
			var _st   = ds_stack_pop(_bst);
			var _bone = _st[0];
			var __x   = _st[1];
			var __w   = _st[2];
			var _sel  = attributes.rigBones == noone? true : array_exists(attributes.rigBones, _bone.ID);
			
			for( var i = 0, n = array_length(_bone.childs); i < n; i++ )
				ds_stack_push(_bst, [ _bone.childs[i], __x + ui(16), __w - ui(16) ]);
				
			if(_bone.is_main) continue;
			var _dx = __x + ui(24);
			var _iy = ty + _hh / 2;
			
	        draw_sprite_stretched_ext(THEME.checkbox_def, 0, _x + ui(16), ty + ui(4), ui(20), ui(20), c_white);
			
				 if(_bone.parent_anchor) draw_sprite_ui(THEME.bone, 1, _dx + ui(12), _iy, 1, 1, 0, COLORS._main_icon);
			else if(_bone.IKlength)      draw_sprite_ui(THEME.bone, 2, _dx + ui(12), _iy, 1, 1, 0, COLORS._main_icon);
			else                         draw_sprite_ui(THEME.bone, 0, _dx + ui(12), _iy, 1, 1, 0, COLORS._main_icon);
			
			var  cc  = _sel? COLORS._main_text : COLORS._main_text_sub;
			if(brush_bone_target == _bone.ID) cc = COLORS._main_value_positive;
			
			var _hov = _hover && point_in_rectangle(_m[0], _m[1], _x, ty, _x + _w, ty + _hh - 1);
				
			if(_hov) {
				cc = COLORS._main_accent;
				anchor_selecting = [ _bone, 2 ];
				
				if(_m[0] < _x + ui(36)) {
					draw_sprite_stretched_ext(THEME.checkbox_def, 1, _x + ui(16), ty + ui(4), ui(20), ui(20), c_white);
					TOOLTIP = "Include in autoweight";
					
					if(mouse_press(mb_left, _focus)) {
						if(attributes.rigBones == noone)
							attributes.rigBones = [];
						array_toggle(attributes.rigBones, _bone.ID);
					}
					
				} else {
					if(mouse_press(mb_left, _focus))
						attributes.rigBones = [ _bone.ID ];
				}
			}
			
			if(_sel) draw_sprite_stretched_ext(THEME.checkbox_def, 2, _x + ui(16), ty + ui(4), ui(20), ui(20), COLORS._main_accent);
			
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text_add(_dx + ui(24), ty + ui(12), _bone.name);
			
			if(_hov && attributes.baked) {
				var _ix = _x + _w - ui(20);
				var _cc = COLORS._main_icon;
				
				if(_m[0] > _ix - ui(12)) {
					_cc = COLORS._main_value_negative;
					TOOLTIP = "Clear weight";
					
					if(mouse_press(mb_left, _focus) && struct_has(attributes.bakeData, _bone.ID)) {
						var _wdata = attributes.bakeData[$ _bone.ID];
						for( var i = 0, n = array_length(_wdata); i < n; i++ ) 
							_wdata[i] = 0;
					}
				}
				
				draw_sprite_ui(THEME.icon_delete, 0, _ix, _iy, 1, 1, 0, _cc);
			}
			
			ty += _hh;
			
			if(!ds_stack_empty(_bst)) {
				draw_set_color(COLORS.node_composite_separator);
				draw_line(_x + ui(16), ty, _x + _w - ui(16), ty);
			}
		}
		
		ds_stack_destroy(_bst);
		
		layer_renderer.h = _bh;
		return layer_renderer.h;

	});
	
	auto_button      = button(function() /*=>*/ {return AutoWeightPaint()}).setText("Auto weight");
	bake_button      = button(function() /*=>*/ {return bake()}).setText("Bake mesh");
	normalize_button = button(function() /*=>*/ {return normalizeWeight()}).setText("Normalize weight");
	
	input_display_list = [ 0, 1, 
		["Armature", false], layer_renderer, 
		["Weight",   false], 3, auto_button, new Inspector_Spacer(ui(8)), bake_button, normalize_button, 
	];
	
	anchor_selecting = noone;
	posing_bone  = noone;
	posing_input = 0;
	posing_type  = 0;
	posing_sx    = 0;
	posing_sy    = 0;
	posing_sz    = 0;
	posing_mx    = 0;
	posing_my    = 0;
	
	brush_drawing   = false;
	brush_draw_mask = [];
	brush_bone_target = noone;
	
	current_bone = noone;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _bones = inputs[0].getValue();
		var _mesh  = inputs[1].getValue();
		var _rdata = attributes.baked? attributes.bakeData : rigdata;
		var _boneTargetID = noone;
		brush_bone_target = noone;
		
		__weights = anchor_selecting == noone? noone : struct_try_get(_rdata, anchor_selecting[0].ID, noone);
		
		if(isUsingTool("Weight Brush") || isUsingTool("Weight Eraser")) {
			if(!is_array(attributes.rigBones)) attributes.rigBones = [ bone_array[0].ID ];
			
			var _boneTargetID = array_safe_get(attributes.rigBones, 0, noone);
			var _boneTarget   = noone;
			
			for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
	        	if(bone_array[i].ID == _boneTargetID) {
	        		_boneTarget = bone_array[i];
	        		break;
	        	}
	        }
	        
	        brush_bone_target = _boneTargetID;
	        var _weightData = _rdata[$ _boneTargetID];
	        if(__weights == noone)
	        	__weights = _weightData;
		}
		
		if(_mesh != noone) {
			__x = _x;
			__y = _y;
			__s = _s;
			
			draw_set_circle_precision(4);
			
			draw_set_alpha(.5);
			array_foreach(_mesh.links, function(_l) /*=>*/ {
				var _p0 = _l.p0;
				var _p1 = _l.p1;
				var _c0 = _p0.color;
				var _c1 = _p1.color;
				
				draw_line_color(_p0.drx, _p0.dry, _p1.drx, _p1.dry, _c0, _c1);
			});
			draw_set_alpha(1);
			
			if(__weights == noone) {
				array_foreach(_mesh.points, function(_p) /*=>*/ {
					if(!is(_p, MeshedPoint)) return;
					
					_p.drx = __x + _p.x * __s;
					_p.dry = __y + _p.y * __s;
					_p.color = COLORS._main_accent;
					
					draw_set_color(_p.color);
					draw_circle(_p.drx, _p.dry, attributes.display_mesh_size, false);
				});
				
			} else {
				array_foreach(_mesh.points, function(_p, i) /*=>*/ {
					if(!is(_p, MeshedPoint)) return;
					
					_p.drx = __x + _p.x * __s;
					_p.dry = __y + _p.y * __s;
					var _w = array_safe_get_fast(__weights, i);
					_p.color = _w > .5? merge_color(COLORS._main_value_negative, COLORS._main_value_positive, (_w - .5) * 2) : 
					                    merge_color(CDEF.main_dkblack, COLORS._main_value_negative, _w);
					
					draw_set_color(_p.color);
					draw_circle(_p.drx, _p.dry, attributes.display_mesh_size, false);
				});
			}
			
		}
		
		if(bone_posed == noone) return;
		
		var mx  = (_mx - _x) / _s;
		var my  = (_my - _y) / _s;
		var smx = value_snap(mx, _snx);
		var smy = value_snap(my, _sny);
		
		if(isUsingTool("Pose")) {
			anchor_selecting = bone_posed.draw(attributes, active * 0b111, _x, _y, _s, _mx, _my, anchor_selecting, posing_bone);
			
			if(posing_bone) {
				if(posing_type == 0 && posing_bone.parent) { //move
					var ang = posing_bone.parent.pose_rotate;
					var pp  = point_rotate(smx - posing_mx, smy - posing_my, 0, 0, -ang);
					var bx  = posing_sx + pp[0];
					var by  = posing_sy + pp[1];
					
					posing_input[TRANSFORM.pos_x] = bx;
					posing_input[TRANSFORM.pos_y] = by;
					triggerRender();
					
				} else if(posing_type == 1) { //scale
					var ss  = point_distance(posing_mx, posing_my, smx, smy) / posing_sx;
					var ori = posing_bone.getHead();
					var ang = point_direction(ori.x, ori.y, smx, smy);
					var rot = ang - posing_sy - posing_bone.parent.pose_rotate;
					
					posing_input[TRANSFORM.sca_x] = ss;
					posing_input[TRANSFORM.rot]   = rot;
					triggerRender();
					
				} else if(posing_type == 2) { //rotate
					var ori = posing_bone.getHead();
					var ang = point_direction(ori.x, ori.y, mx, my);
					var rot = angle_difference(ang, posing_sy);
					posing_sy = ang;
					posing_sx += rot;
					
					posing_input[TRANSFORM.rot] = posing_sx;
					triggerRender();
				}
				
				if(mouse_release(mb_left)) {
					posing_bone = noone;
					posing_type = noone;
					UNDO_HOLDING = false;
				}
			}
			
			if(anchor_selecting != noone && mouse_press(mb_left, active)) {
				posing_bone = anchor_selecting[0];
				if(!struct_has(attributes.bonePoseData, posing_bone.ID))
					attributes.bonePoseData[$ posing_bone.ID] = [ 0, 0, 0, 1, 1 ];
				posing_input = attributes.bonePoseData[$ posing_bone.ID];
				
				if(anchor_selecting[1] == 0 || anchor_selecting[0].IKlength) { // move
					
					posing_type = 0;
					
					posing_sx = posing_input[TRANSFORM.pos_x];
					posing_sy = posing_input[TRANSFORM.pos_y];
					
					var _p = anchor_selecting[2];
					posing_mx = _p.x;
					posing_my = _p.y;
					
				} else if(anchor_selecting[1] == 1) { // scale
					
					posing_type = 1;
					
					var ori = posing_bone.getHead();
					posing_sx = posing_bone.length / posing_bone.pose_scale * posing_bone.parent.pose_scale;
					posing_sy = posing_bone.angle - posing_bone.pose_local_rotate;
					posing_sz = point_direction(ori.x, ori.y, smx, smy);
					
					var pnt = posing_bone.getHead();
					posing_mx = pnt.x;
					posing_my = pnt.y;
					
				} else if(anchor_selecting[1] == 2) { // rotate
					
					posing_type = 2;
					
					var ori = posing_bone.getHead();
					posing_sx = posing_input[TRANSFORM.rot];
					posing_sy = point_direction(ori.x, ori.y, mx, my);
					
					posing_mx = mx;
					posing_my = my;
				}
			}
			return;
		} 
		
		if(isUsingTool("Weight Brush") || isUsingTool("Weight Eraser")) {
			if(_boneTargetID == noone) return;
			
			draw_set_color(COLORS._main_icon);
			draw_set_circle_precision(32);
			
			var _rad = tool_attribute.size;
			draw_circle(_mx, _my, _rad, true);
			
			var _r = _rad / _s;
			var _pnts = _mesh.points;
        	var _plen = array_length(_pnts);
        	
			if(brush_drawing) {
				var _weight = tool_attribute.weight;
				if(isUsingTool("Weight Eraser")) _weight = -_weight;
				
				for( var i = 0; i < _plen; i++ ) {
					var _p  = _pnts[i];
					if(!is_struct(_p)) continue;
					
					var _d  = point_distance(_p.x, _p.y, mx, my);
					var _ww = 1 - _d / _r;
					if(_ww <= 0) continue;
					
					var _w = _weight * min(_ww * 2, 1);
					if(brush_draw_mask[i] >= abs(_w)) continue;
					
					brush_draw_mask[i]   = abs(_w);
					brush_draw_orig[i] ??= _weightData[i];
					
					_weightData[i] = clamp(brush_draw_orig[i] + _w, 0, 1);
				}
				
				if(mouse_release(mb_left)) {
					brush_drawing = false;
					triggerRender();
				}
			}
			
			if(hover && mouse_press(mb_left, active)) {
				brush_drawing   = true;
				brush_draw_mask = array_create(_plen, 0);
				brush_draw_orig = array_create(_plen, undefined);
			}
			
			if(_boneTarget != noone) _boneTarget.drawBone(attributes, false, _x, _y, _s, _mx, _my, noone, noone, c_white, 1);
			return;
		}
		
        for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
        	var _b = bone_array[i];
        	var _l = attributes.rigBones == noone || array_exists(attributes.rigBones, _b.ID);
			_b.drawBone(attributes, false, _x, _y, _s, _mx, _my, anchor_selecting, noone, c_white, 0.25 + _l * 0.75);
        }
	}
	
	static AutoWeightPaint = function(_render = true) {
        var _mesh  = inputs[1].getValue();
        var _rad   = inputs[3].getValue();
        
        if(!is(bone_posed, __Bone))    return;
        if(!is(_mesh,  MeshedSurface)) return;
        
        rigdata = {};
        
        var _pnts = _mesh.points;
        var _plen = array_length(_pnts);
        
        var _boneArr = bone_posed.toArray();
        var _boneDat = [];
        var _boneAmo = array_length(_boneArr);
        
        for( var i = 0; i < _boneAmo; i++ ) {
            var _b  = _boneArr[i];
            if(attributes.rigBones != noone && !array_exists(attributes.rigBones, _b.ID)) continue;
            
            array_push(_boneDat, {
                b  : _b,
                ID : _b.ID,
                p0 : _b.getHead(),
                p1 : _b.getTail(),
            });
            
            rigdata[$ _b.ID] = array_create(_plen, 0);
        }
        
        var _boneAmo = array_length(_boneDat);
        
        for( var i = 0, n = _plen; i < n; i++ ) {
            var _p  = _pnts[i];
            if(!is(_p, MeshedPoint)) continue;
            
            var _px = _p.x;
            var _py = _p.y;
            
            var _minDist = 9999;
            var _minBone = noone;
            var _boneWi  = array_create(_boneAmo, 0);
            
            for( var j = 0; j < _boneAmo; j++ ) {
                var _b = _boneDat[j];
                
                var _dist  = distance_to_line(_px, _py, _b.p0.x, _b.p0.y, _b.p1.x, _b.p1.y);
                _boneWi[j] = _dist;
                
                if(_dist < _minDist) {
                    _minDist = _dist;
                    _minBone = _b.ID;
                }
            }
            
            if(_minBone == noone) continue;
            
            if(_minDist >= _rad) {
            	rigdata[$ _minBone][i] = 1;
            	continue;
            }
            
            var _totalWeight = 0;
            for( var j = 0; j < _boneAmo; j++ ) {
            	_boneWi[j] = max(_rad - _boneWi[j], 0);
            	_totalWeight += _boneWi[j];
            }
            
            for( var j = 0; j < _boneAmo; j++ ) {
            	_boneWi[j] /= _totalWeight;
            	var _b = _boneDat[j];
            	
            	rigdata[$ _b.ID][i] = _boneWi[j];
            }
        }
        
        if(_render) triggerRender();
	}
	
	static step = function() {
		auto_button.interactable = !attributes.baked;
		bake_button.text  = attributes.baked? "Unbake" : "Bake mesh";
		bake_button.blend = attributes.baked? COLORS._main_value_negative : c_white;
		tools = attributes.baked? tools_baked : tools_dynamic;
	}
	
    static update = function() {
        var _bones = inputs[0].getValue();
        var _mesh  = inputs[1].getValue();
        
        if(!is(_bones, __Bone))        return;
        if(!is(_mesh,  MeshedSurface)) return;
        
        var _map  = {};
        
		current_bone = _bones;
        bone_posed   = _bones.clone()
							 .connect()
							 .resetPose();
		bone_posed.constrains = _bones.constrains;
		
		bone_array = bone_posed.toArray();
		for( var i = 0, n = array_length(bone_array); i < n; i++ ) {
			var _b = bone_array[i];
			
			_map[$ _b.ID] = _b;
			if(!struct_has(attributes.bonePoseData, _b.ID)) continue;
			
			var _trn       = attributes.bonePoseData[$ _b.ID];
			_b.pose_posit  = [ _trn[TRANSFORM.pos_x], _trn[TRANSFORM.pos_y] ];
			_b.pose_rotate =   _trn[TRANSFORM.rot];
			_b.pose_scale  =   _trn[TRANSFORM.sca_x];
		}
		
		bone_posed.setPose(false);
		bone_bbox = bone_posed.bbox();
		
        if(!attributes.baked && rigdata == noone)
        	AutoWeightPaint(false);
        
        var _rdata          = attributes.baked? attributes.bakeData : rigdata;
        var _meshRigged     = new RiggedMeshedSurface();
        _meshRigged.rigMap  = _rdata;
        _meshRigged.mesh    = _mesh.clone();
        _meshRigged.bone    = bone_posed;
        _meshRigged.boneMap = _map;
        
        outputs[0].setValue(_meshRigged);
    }
    
    static bake = function() {
    	if(attributes.baked) { attributes.baked = false; return; }
    	
    	attributes.baked = true;
    	var _dat = {};
    	var _k = struct_get_names(rigdata);
    	
    	for( var i = 0, n = array_length(_k); i < n; i++ )
    		_dat[$ _k[i]] = array_clone(rigdata[$ _k[i]]);
    	
    	attributes.bakeData = _dat;
    }
    
    static normalizeWeight = function() {
    	if(!attributes.baked) return;
    	
    	var _mesh  = inputs[1].getValue();
        if(!is(_mesh,  MeshedSurface)) return;
        
    	var _wdata = attributes.bakeData;
        var _wkeys = struct_get_names(_wdata);
        
        var _plen = array_length(_mesh.points);
        
        for( var i = 0; i < _plen; i++ ) {
        	
            var _totalWeight = 0;
            for( var j = 0, m = array_length(_wkeys); j < m; j++ )
            	_totalWeight += _wdata[$ _wkeys[j]][i];
            if(_totalWeight == 0) continue;
            
            for( var j = 0, m = array_length(_wkeys); j < m; j++ )
            	_wdata[$ _wkeys[j]][i] /= _totalWeight;
        }
        
        triggerRender();
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    static getGraphPreviewSurface = function() { return noone; }
    
    static getPreviewValues = function() {
    	var _mesh = inputs[1].getValue();
    	return is(_mesh, MeshedSurface)? _mesh.surface : noone;
    }
    
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(bone_posed != noone) {
			var _ss = _s * .5;
			gpu_set_tex_filter(1);
			draw_sprite_ext(s_node_armature_mesh_rig, 0, bbox.x0 + 24 * _ss, bbox.y1 - 24 * _ss, _ss, _ss, 0, c_white, 0.5);
			gpu_set_tex_filter(0);
			
			bone_posed.drawThumbnail(_s, bbox, bone_bbox);
			
		} else {
			gpu_set_tex_filter(1);
			draw_sprite_fit(s_node_armature_mesh_rig, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
			gpu_set_tex_filter(0);
		}
	}
}