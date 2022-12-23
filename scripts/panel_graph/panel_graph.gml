function Panel_Graph() : PanelContent() constructor {
	context_str = "Graph";
	
	scale			= [ 0.25, 0.33, 0.5, 0.65, 0.8, 1, 1.2, 1.35, 1.5];
	graph_s_index	= 5;
	graph_s			= ui(scale[graph_s_index]);
	graph_s_to		= graph_s;
	graph_line_s	= 32;
	grid_color      = c_white;
	grid_opacity	= 0.05;
	
	function toOrigin() {
		graph_x = round(w / 2 / graph_s);
		graph_y = round(h / 2 / graph_s);
	}
	
	function initSize() {
		toOrigin();
	}
	initSize();
	
	graph_dragging = false;
	graph_drag_mx  = 0;
	graph_drag_my  = 0;
	graph_drag_sx  = 0;
	graph_drag_sy  = 0;
	
	mouse_graph_x = 0;
	mouse_graph_y = 0;
	mouse_grid_x = 0;
	mouse_grid_y = 0;
	mouse_on_graph = false;
	
	nodes_list = NODES;
	node_context = ds_list_create();
	
	node_dragging = noone;
	node_drag_mx  = 0;
	node_drag_my  = 0;
	node_drag_sx  = 0;
	node_drag_sy  = 0;
	node_drag_ox  = 0;
	node_drag_oy  = 0;
	node_drag_snap = true;
	
	selection_block		= 0;
	nodes_select_list	= ds_list_create();
	nodes_select_drag   = false;
	nodes_select_mx     = 0;
	nodes_select_my     = 0;
	
	node_hovering		= noone;
	node_hover			= noone;
	node_focus			= noone;
	
	junction_hovering = noone;
	
	value_focus    = noone;
	value_dragging = noone;
	
	show_grid = true;
	drag_key  = mb_middle;
	
	minimap_show = false;
	minimap_w = ui(160);
	minimap_h = ui(160);
	minimap_surface = -1;
	
	minimap_panning  = false;
	minimap_dragging = false;
	minimap_drag_sx = 0;
	minimap_drag_sy = 0;
	minimap_drag_mx = 0;
	minimap_drag_my = 0;
	
	context_framing = false;
	context_frame_progress = 0;
	context_frame_direct   = 0;
	context_frame_sx = 0; context_frame_ex = 0;
	context_frame_sy = 0; context_frame_ey = 0;
	
	drag_locking = false;
	
	toolbar_height = ui(40);
	toolbars = [
		[ 
			THEME.icon_center_canvas,
			function() { return 0;  },
			function() { return "Center to nodes" }, 
			function() { toCenterNode(); } 
		],
		[ 
			THEME.icon_minimap,
			function() { return minimap_show;  },
			function() { return minimap_show? "Minimap enabled" : "Minimap disabled" }, 
			function() { minimap_show = !minimap_show; } 
		],
		[ 
			THEME.icon_curve_connection,
			function() { return PREF_MAP[? "curve_connection_line"];  },
			function() { 
				switch(PREF_MAP[? "curve_connection_line"]) {
					case 0 : return "Straight connection line";
					case 1 : return "Curve connection line";
					case 2 : return "Elbow connection line";
				}
			}, 
			function() { PREF_MAP[? "curve_connection_line"] = (PREF_MAP[? "curve_connection_line"] + 1) % 3; } 
		],
		[ 
			THEME.icon_grid_setting,
			function() { return 0; },
			function() { return "Grid setting" }, 
			function(param) { 
				var gs = dialogCall(o_dialog_graph_grid, param.x, param.y); 
				gs.anchor = ANCHOR.bottom | ANCHOR.left;
			} 
		],
	];
	
	addHotkey("Graph", "Add node",			    "A", MOD_KEY.none,	function() { callAddDialog(); });
	addHotkey("Graph", "Focus content",			"F", MOD_KEY.none,	function() { fullView(); });
	addHotkey("Graph", "Preview focusing node",	"P", MOD_KEY.none,	function() { setCurrentPreview(); });
	addHotkey("Graph", "Import image",			"I", MOD_KEY.none,	function() { nodeBuild("Node_Image", mouse_grid_x, mouse_grid_y); });
	addHotkey("Graph", "Import image array",	"I", MOD_KEY.shift,	function() { nodeBuild("Node_Image_Sequence", mouse_grid_x, mouse_grid_y); });
	addHotkey("Graph", "Add number",			"1", MOD_KEY.none,	function() { nodeBuild("Node_Number",  mouse_grid_x, mouse_grid_y); });
	addHotkey("Graph", "Add vector2",			"2", MOD_KEY.none,	function() { nodeBuild("Node_Vector2", mouse_grid_x, mouse_grid_y); });
	addHotkey("Graph", "Add vector3",			"3", MOD_KEY.none,	function() { nodeBuild("Node_Vector3", mouse_grid_x, mouse_grid_y); });
	addHotkey("Graph", "Add vector4",			"4", MOD_KEY.none,	function() { nodeBuild("Node_Vector4", mouse_grid_x, mouse_grid_y); });
	
	static addNodeTransform = function() {
		if(ds_list_empty(nodes_select_list)) {
			if(node_focus != noone && !ds_list_empty(node_focus.outputs)) {
				var _o = node_focus.outputs[| 0];
				if(_o.type == VALUE_TYPE.surface) {
					var tr = nodeBuild("Node_Transform", node_focus.x + node_focus.w + 64, node_focus.y);
					tr.inputs[| 0].setFrom(_o);
				}
			}
		} else {
			for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {	
				var node = nodes_select_list[| i];
				if(ds_list_empty(node.outputs)) continue;
				
				var _o = node.outputs[| 0];
				if(_o.type == VALUE_TYPE.surface) {
					var tr = nodeBuild("Node_Transform", node.x + node.w + 64, node.y);
					tr.inputs[| 0].setFrom(_o);
				}
			}
		}
	}
	addNodeTransform = method(self, addNodeTransform);
	addHotkey("Graph", "Transform node",		"T", MOD_KEY.ctrl,	addNodeTransform);
	
	addHotkey("Graph", "Select all",	"A", MOD_KEY.ctrl,	function() { 
		ds_list_clear(nodes_select_list); 
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			ds_list_add(nodes_select_list, nodes_list[| i]);	
		}
	});
	addHotkey("Graph", "Duplicate",		"D", MOD_KEY.ctrl,		function() { doDuplicate(); });
	
	addHotkey("Graph", "Toggle grid",	"G", MOD_KEY.none,		function() { show_grid = !show_grid; });
	
	addHotkey("Graph", "Export",	"E", MOD_KEY.ctrl,	function() { setCurrentExport(); });
	
	addHotkey("Graph", "Blend",		"B", MOD_KEY.ctrl,	function() { doBlend(); });
	addHotkey("Graph", "Compose",	"B", MOD_KEY.ctrl | MOD_KEY.shift,	function() { doCompose(); });
	
	addHotkey("Graph", "Group",		"G", MOD_KEY.ctrl,					function() { doGroup(); });
	addHotkey("Graph", "Ungroup",	"G", MOD_KEY.ctrl | MOD_KEY.shift,	function() { doUngroup(); });
	
	addHotkey("Graph", "Loop",		"L", MOD_KEY.ctrl,					function() { doLoop(); });
	
	addHotkey("Graph", "Canvas",		"C", MOD_KEY.ctrl | MOD_KEY.shift,		function() { setCurrentCanvas(); });
	addHotkey("Graph", "Canvas blend",	"C", MOD_KEY.ctrl | MOD_KEY.alt,		function() { setCurrentCanvasBlend(); });
	
	addHotkey("Graph", "Frame",		"F", MOD_KEY.ctrl,					function() { doFrame(); });
	
	addHotkey("Graph", "Delete (break)",	vk_delete, MOD_KEY.shift,	function() { doDelete(false); });
	addHotkey("Graph", "Delete (merge)",	vk_delete, MOD_KEY.none,	function() { doDelete(true); });
	
	function stepBegin() {
		var gr_x = graph_x * graph_s;
		var gr_y = graph_y * graph_s;
		var m_x  = (mx - gr_x) / graph_s;
		var m_y  = (my - gr_y) / graph_s;
		mouse_graph_x = m_x;
		mouse_graph_y = m_y;
		
		mouse_grid_x = round(m_x / graph_line_s) * graph_line_s;
		mouse_grid_y = round(m_y / graph_line_s) * graph_line_s;
	}
	
	function toCenterNode() {
		if(ds_list_empty(nodes_list)) {
			toOrigin();
			return;
		}
		
		var minx =  99999;
		var maxx = -99999;
		var miny =  99999;
		var maxy = -99999;
			
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			var n = nodes_list[| i];
			minx = min(n.x - 32, minx);
			maxx = max(n.x + n.w + 32, maxx);
				
			miny = min(n.y - 32, miny);
			maxy = max(n.y + n.h + 32, maxy);
		}
		
		graph_x = round(w / 2 / graph_s - (minx + maxx) / 2);
		graph_y = round((h - toolbar_height) / 2 / graph_s - (miny + maxy) / 2);
	}
	
	function dragGraph() {
		if(graph_dragging) {
			if(!MOUSE_WRAPPING) {
				var dx = mx - graph_drag_mx; 
				var dy = my - graph_drag_my;
			
				graph_x += dx / graph_s;
				graph_y += dy / graph_s;
			}
				
			graph_drag_mx = mx;
			graph_drag_my = my;
			setMouseWrap();
			
			if(mouse_release(drag_key)) 
				graph_dragging = false;
		}
		
		if(mouse_on_graph && pFOCUS) {
			var _doDragging = false;
			if(mouse_press(mb_middle)) {
				_doDragging = true;
				drag_key = mb_middle;
			} else if(mouse_press(mb_left) && key_mod_press(CTRL)) {
				_doDragging = true;
				drag_key = mb_left;
			}
			
			if(_doDragging) {
				graph_dragging = true;	
				graph_drag_mx  = mx;
				graph_drag_my  = my;
				graph_drag_sx  = graph_x;
				graph_drag_sy  = graph_y;
			}
		}
		
		if(mouse_on_graph && pHOVER) {
			var _s = graph_s;
			if(mouse_wheel_down()) {
				graph_s_index = max(0, graph_s_index - 1);
				graph_s_to = ui(scale[graph_s_index]);
			}
			if(mouse_wheel_up()) {
				graph_s_index = min(array_length(scale) - 1, graph_s_index + 1);
				graph_s_to = ui(scale[graph_s_index]);
			}
			graph_s = lerp_float(graph_s, graph_s_to, PREF_MAP[? "graph_zoom_smoooth"]);
			
			if(_s != graph_s) {
				var mb_x = (mx - graph_x * _s) / _s;
				var ma_x = (mx - graph_x * graph_s) / graph_s;
				var md_x = ma_x - mb_x;
				graph_x += md_x;
				
				var mb_y = (my - graph_y * _s) / _s;
				var ma_y = (my - graph_y * graph_s) / graph_s;
				var md_y = ma_y - mb_y;
				graph_y += md_y;
			}
		}
		
		graph_x = round(graph_x);
		graph_y = round(graph_y);
	}
	
	function drawGrid() {
		var gr_x  = graph_x * graph_s;
		var gr_y  = graph_y * graph_s;
		var gr_ls = graph_line_s * graph_s;
		var xx = -gr_ls, xs = safe_mod(gr_x, gr_ls);
		var yy = -gr_ls, ys = safe_mod(gr_y, gr_ls);
		
		draw_set_color(grid_color);
		draw_set_alpha(grid_opacity * (graph_s >= 1? 1 : 0.5));
		while(xx < w + gr_ls) {
			draw_line(xx + xs, 0, xx + xs, h);
			if(xx + xs - gr_x == 0) {
				draw_line_width(xx + xs, 0, xx + xs, h, 3);
			}
			xx += gr_ls;
		}
		
		while(yy < h + gr_ls) {
			draw_line(0, yy + ys, w, yy + ys);
			if(yy + ys - gr_y == 0) {
				draw_line_width(0, yy + ys, w, yy + ys, 3);
			}
			yy += gr_ls;
		}
		draw_set_alpha(1);
	}
	
	function drawNodes() {
		if(selection_block-- > 0) return;
		
		var gr_x = graph_x * graph_s;
		var gr_y = graph_y * graph_s;
		
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			nodes_list[| i].preDraw(gr_x, gr_y, graph_s);
		}
		
		#region draw frame
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				if(instanceof(nodes_list[| i]) != "Node_Frame") continue;
				nodes_list[| i].drawNode(gr_x, gr_y, mx, my, graph_s);
			}
		#endregion
		
		#region hover
			node_hovering = noone;
			if(pHOVER)
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var n = nodes_list[| i];
				if(n.pointIn(gr_x, gr_y, mx, my, graph_s))
					node_hovering = n;	
			}
		#endregion
		
		if(mouse_on_graph && pFOCUS) {
			if(mouse_press(mb_left) && !key_mod_press(CTRL)) {
				if(keyboard_check(vk_shift)) {
					if(ds_list_empty(nodes_select_list) && node_focus) 
						ds_list_add(nodes_select_list, node_focus);
					if(node_focus != node_hovering)
						ds_list_add(nodes_select_list, node_hovering);
				} else {
					node_focus = node_hovering;	
					if(node_focus) {
						if(instanceof(node_focus) == "Node_Frame") {
							var fx0 = (node_focus.x + graph_x) * graph_s;
							var fy0 = (node_focus.y + graph_y) * graph_s;
							var fx1 = fx0 + node_focus.w * graph_s;
							var fy1 = fy0 + node_focus.h * graph_s;
						
							ds_list_clear(nodes_select_list);
							for(var i = 0; i < ds_list_size(nodes_list); i++) {
								var _node = nodes_list[| i];
								if(instanceof(_node) == "Node_Frame") continue;
								var _x = (_node.x + graph_x) * graph_s;
								var _y = (_node.y + graph_y) * graph_s;
								var _w = _node.w * graph_s;
								var _h = _node.h * graph_s;
								
								if(rectangle_inside_rectangle(fx0, fy0, fx1, fy1, _x, _y, _x + _w, _y + _h))
									ds_list_add(nodes_select_list, _node);	
							}
							ds_list_add(nodes_select_list, node_focus);	
						} else if(node_focus.previewable && DOUBLE_CLICK) {
							PANEL_PREVIEW.setNodePreview(node_focus);
						} else {
							var hover_selected = false;	
							for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
								if(nodes_select_list[| i] == node_focus) {
									hover_selected = true;
									break;
								}
							}
							if(!hover_selected)
								ds_list_clear(nodes_select_list);
						}
					} else {
						ds_list_clear(nodes_select_list);
					}
				}
			}
			
			if(mouse_press(mb_right)) {
				node_hover = node_hovering;	
				if(node_hover) {
					var dia = dialogCall(o_dialog_menubox, mouse_mx + 8, mouse_my + 8);
					var menu = [];
					array_push(menu,  
						[ "Send to preview", function() {
							setCurrentPreview(node_hover);
						}]);
					array_push(menu,  
						[ "Send to export", function() {
							setCurrentExport(node_hover);
						}, ["Graph", "Export"] ]);
					array_push(menu,  
						[ "Delete and merge connection", function() {
							doDelete(true);
						}, ["Graph", "Delete (merge)"] ]);
					array_push(menu,  
						[ "Delete and cut connection", function() {
							doDelete(false);
						}, ["Graph", "Delete (break)"] ]);
					array_push(menu,  
						[ "Duplicate", function() {
							doDuplicate();
						}, ["Graph", "Duplicate"] ]);
					
					array_push(menu, -1);
					array_push(menu, [ "Add transform", addNodeTransform, ["Graph", "Transform node"] ]);
					array_push(menu, [ "Canvas",
						function(_x, _y, _depth) { 
							var dia = instance_create_depth(_x - 4, _y, _depth - 1, o_dialog_menubox);
							dia.setMenu([
								[ "Copy to canvas", function() {
									setCurrentCanvas(node_hover);
								}, ["Graph", "Canvas"] ],
								[ "Overlay canvas", function() {
									setCurrentCanvasBlend(node_hover);
								}, ["Graph", "Canvas blend"] ]
							]);
							return dia;
						}, ">"
					]);
					
					if(!ds_list_empty(nodes_select_list)) {
						array_push(menu, -1);
						array_push(menu,  
							[ "Blend nodes", function() { 
								doBlend();
							}, ["Graph", "Blend"] ]);
						array_push(menu,  
							[ "Compose nodes", function() { 
								doCompose();
							}, ["Graph", "Compose"] ]);
						
						array_push(menu,  
							[ "Group nodes", function() { 
								doGroup();
							}, ["Graph", "Group"] ]);	
						
						array_push(menu,  
							[ "Frame nodes", function() { 
								doFrame();
							}, ["Graph", "Frame"] ]);	
					} else if(variable_struct_exists(node_hover, "nodes")) {
						array_push(menu,  
							[ "Ungroup", function() { 
								doUngroup();
							}, ["Graph", "Ungroup"] ]);		
					}
					
					dia.setMenu( menu );
				} else {
					callAddDialog();
				}
			}
		}
		
		if(node_hovering && node_hovering.on_dragdrop_file != -1)
			node_hovering.drawActive(gr_x, gr_y, graph_s, 1);
		
		if(node_focus)
			node_focus.drawActive(gr_x, gr_y, graph_s);
		
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			_node.drawActive(gr_x, gr_y, graph_s);
		}
		
		var hov = noone;
		var hoverable = !bool(node_dragging);
		for(var i = 0; i < ds_list_size(nodes_list); i++) {
			var _hov = nodes_list[| i].drawConnections(gr_x, gr_y, graph_s, mx, my, hoverable);
			if(_hov != noone) hov = _hov;
		}
		
		junction_hovering = node_hovering == noone? hov : noone;
		
		value_focus = noone;
		
		#region draw node
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var n = nodes_list[| i];
				if(instanceof(n) == "Node_Frame") continue;
				var val = n.drawNode(gr_x, gr_y, mx, my, graph_s);
				if(val) value_focus = val;
			}
			
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				nodes_list[| i].drawBadge(gr_x, gr_y, graph_s);	
				nodes_list[| i].drawJunctionNames(gr_x, gr_y, mx, my, graph_s);	
			}
		#endregion
		
		#region dragging
			if(mouse_release(mb_left) || mouse_press(mb_left))
				node_dragging = noone;
			if(node_dragging) {
				node_focus = node_dragging;
			
				for(var i = 0; i < ds_list_size(nodes_list); i++) {
					var _node = nodes_list[| i];
					
					if(_node.pointIn(gr_x, gr_y, mx, my, graph_s) && variable_struct_exists(_node, "nodes")) {
						var _recur = false;
						if(ds_list_size(nodes_select_list) == 0) {
							if(_node == node_dragging) _recur = true;	
						} else {
							for(var j = 0; j < ds_list_size(nodes_select_list); j++) {
								var _n = nodes_select_list[| j];
								if(_node == _n) _recur = true;
							}
						}
					
						if(!_recur) {
							_node.drawActive(gr_x, gr_y, graph_s, 1);
							if(mouse_release(mb_left) && !key_mod_press(CTRL)) {
								if(ds_list_size(nodes_select_list) == 0) {
									_node.add(node_dragging);
									node_dragging.checkConnectGroup();
								} else {
									for(var j = 0; j < ds_list_size(nodes_select_list); j++) {
										_node.add(nodes_select_list[| j]);
									}
									for(var j = 0; j < ds_list_size(nodes_select_list); j++) {
										nodes_select_list[| j].checkConnectGroup();
									}
								}
							}
						}
					}
				}
			
				if(ds_list_size(nodes_select_list) == 0) {
					var nx = node_drag_sx + (mouse_graph_x - node_drag_mx);
					var ny = node_drag_sy + (mouse_graph_y - node_drag_my);
					
					if(!key_mod_press(CTRL) && node_drag_snap) {
						nx = round(nx / graph_line_s) * graph_line_s;
						ny = round(ny / graph_line_s) * graph_line_s;
					}
					
					node_dragging.move(nx, ny);
				
					if(mouse_release(mb_left) && !key_mod_press(CTRL)) {
						if(nx != node_drag_sx || ny != node_drag_sy) {
							recordAction(ACTION_TYPE.var_modify, node_dragging, [ node_drag_sx, "x" ]);
							recordAction(ACTION_TYPE.var_modify, node_dragging, [ node_drag_sy, "y" ]);
						}
					}
				} else {
					var nx = node_drag_sx + (mouse_graph_x - node_drag_mx);
					var ny = node_drag_sy + (mouse_graph_y - node_drag_my);
					
					if(!key_mod_press(CTRL) && node_drag_snap) {
						nx = round(nx / graph_line_s) * graph_line_s;
						ny = round(ny / graph_line_s) * graph_line_s;
					}
					
					if(node_drag_ox == -1 || node_drag_oy == -1) {
						node_drag_ox = nx;
						node_drag_oy = ny;
					} else if(nx != node_drag_ox || ny != node_drag_oy) {
						var dx = nx - node_drag_ox;
						var dy = ny - node_drag_oy;
						
						for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
							var _node = nodes_select_list[| i];
							var _nx = _node.x + dx;
							var _ny = _node.y + dy;
							
							if(!key_mod_press(CTRL) && node_drag_snap) {
								_nx = round(_nx / graph_line_s) * graph_line_s;
								_ny = round(_ny / graph_line_s) * graph_line_s;
							}
							
							_node.move(_nx, _ny);
						}
					
						node_drag_ox = nx;
						node_drag_oy = ny;
					}
				}
			}
		#endregion
		
		if(mouse_on_graph && pFOCUS) {
			if(node_focus && value_focus == noone) {
				if(mouse_press(mb_left) && !key_mod_press(CTRL)) {
					node_dragging = node_focus;
					node_drag_mx  = mouse_graph_x;
					node_drag_my  = mouse_graph_y;
					node_drag_sx  = node_focus.x;
					node_drag_sy  = node_focus.y;
				
					node_drag_ox  = -1;
					node_drag_oy  = -1;
				}
			}
			
			if(DOUBLE_CLICK && junction_hovering != noone) {
				var _mx = round(mouse_graph_x / graph_line_s) * graph_line_s;
				var _my = round(mouse_graph_y / graph_line_s) * graph_line_s;
						
				var _pin = new Node_Pin(_mx, _my);
				_pin.inputs[| 0].setFrom(junction_hovering.value_from);
				junction_hovering.setFrom(_pin.outputs[| 0]);
			}
		}
		
		#region draw selection frame
			if(nodes_select_drag) {
				if(point_distance(nodes_select_mx, nodes_select_my, mx, my) > 16) {
					draw_set_color(COLORS._main_accent);
					draw_roundrect_ext(nodes_select_mx, nodes_select_my, mx, my, 6, 6, true);
					draw_set_alpha(0.05);
					draw_roundrect_ext(nodes_select_mx, nodes_select_my, mx, my, 6, 6, false);
					draw_set_alpha(1);
				
					ds_list_clear(nodes_select_list);
				
					for(var i = 0; i < ds_list_size(nodes_list); i++) {
						var _node = nodes_list[| i];
						if(instanceof(_node) == "Node_Frame") continue;
						var _x = (_node.x + graph_x) * graph_s;
						var _y = (_node.y + graph_y) * graph_s;
						var _w = _node.w * graph_s;
						var _h = _node.h * graph_s;
					
						if(rectangle_in_rectangle(_x, _y, _x + _w, _y + _h, nodes_select_mx, nodes_select_my, mx, my))
							ds_list_add(nodes_select_list, _node);	
					}
				}
			
				if(mouse_release(mb_left))
					nodes_select_drag = false;
			}
		
			if(mouse_on_graph && mouse_press(mb_left, pFOCUS) && !key_mod_press(CTRL)) {
				if(!node_focus && !value_focus && !drag_locking) {
					nodes_select_drag = true;
					nodes_select_mx = mx;
					nodes_select_my = my;
				}
				drag_locking = false;
			}
		#endregion
	}
	
	function doDuplicate() {
		if(ds_list_empty(nodes_select_list)) {
			if(node_focus == noone) return;
			node_dragging = node_focus.clone();
			node_drag_mx  = node_dragging.x;
			node_drag_my  = node_dragging.y;
			node_drag_sx  = node_dragging.x;
			node_drag_sy  = node_dragging.y;
				
			node_drag_ox  = -1;
			node_drag_oy  = -1;
			return;
		}
		
		var dups = ds_list_create();
		ds_map_clear(APPEND_MAP);
		
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			var _cnode = _node.clone();
			ds_list_add(dups, _cnode);
			
			APPEND_MAP[? _node.node_id] = _cnode.node_id;
		}
		
		APPENDING = true;
		for(var i = 0; i < ds_list_size(dups); i++) {
			var _node = dups[| i];
			_node.connect();
		}
		APPENDING = false;
		
		ds_list_destroy(nodes_select_list);
		nodes_select_list = dups;
		
		node_dragging = nodes_select_list[| 0];
		node_drag_mx  = 0;
		node_drag_my  = 0;
		node_drag_sx  = 0;
		node_drag_sy  = 0;
		
		PANEL_ANIMATION.updatePropertyList();
	}
	
	function doBlend() {
		if(ds_list_empty(nodes_select_list)) return;
		if(ds_list_size(nodes_select_list) != 2) return;
		
		var cx = 0;
		var cy = 0;
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			cx = max(cx, _node.x);
			cy += _node.y;
		}
		cx = cx + 160;
		cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
		var _blend = new Node_Blend(cx, cy);
		var index = 0;
		for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
			var _node = nodes_select_list[| i];
			if(ds_list_size(_node.outputs) == 0) continue;
			if(_node.outputs[| 0].type == VALUE_TYPE.surface) {
				_blend.inputs[| index].setFrom(_node.outputs[| 0]);
				index++;
			}
		}
			
		ds_list_clear(nodes_select_list);
	}
	
	function doCompose() {
		if(ds_list_empty(nodes_select_list)) return;
		
		var cx = -99999;
		var cy = 0;
		
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			cx = max(cx, _node.x);
			cy += _node.y;
		}
		cx = cx + 160;
		cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
		var _compose = nodeBuild("Node_Composite", cx, cy);
		
		for( var i = 0; i < ds_list_size(nodes_select_list); i++ ) {
			var _node = nodes_select_list[| i];
			if(ds_list_size(_node.outputs) == 0) continue;
			if(_node.outputs[| 0].type == VALUE_TYPE.surface) {
				_compose.addFrom(_node.outputs[| 0]);
			}
		}
			
		ds_list_clear(nodes_select_list);
	}
	
	function doGroup() {
		if(ds_list_empty(nodes_select_list) && node_focus != noone)
			ds_list_add(nodes_select_list, node_focus);
		node_focus = noone;
		
		if(ds_list_empty(nodes_select_list)) return;
		
		var cx = 0;
		var cy = 0;
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			cx += _node.x;
			cy += _node.y;
		}
		cx = round(cx / ds_list_size(nodes_select_list) / 32) * 32;
		cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
				
		var _group = new Node_Group(cx, cy);
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			_group.add(nodes_select_list[| i]);
		}
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			nodes_select_list[| i].checkConnectGroup();
		}
			
		ds_list_clear(nodes_select_list);
	}
	
	function doUngroup() {
		if(node_focus == noone) return;
		if(!variable_struct_exists(node_focus, "nodes")) return;
		if(!node_focus.ungroupable) return;
		
		while(!ds_list_empty(node_focus.nodes)) {
			node_focus.remove(node_focus.nodes[| 0]); 
		}
		nodeDelete(node_focus);
	}
	
	function doLoop() {
		if(ds_list_empty(nodes_select_list) && node_focus != noone)
			ds_list_add(nodes_select_list, node_focus);
		
		if(ds_list_empty(nodes_select_list)) return;
		
		var cx = 0;
		var cy = 0;
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			var _node = nodes_select_list[| i];
			cx += _node.x;
			cy += _node.y;
		}
		cx = round(cx / ds_list_size(nodes_select_list) / 32) * 32;
		cy = round(cy / ds_list_size(nodes_select_list) / 32) * 32;
		
		var _group = new Node_Iterate(cx, cy);
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			_group.add(nodes_select_list[| i]);
		}
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			nodes_select_list[| i].checkConnectGroup("loop");
		}
			
		ds_list_clear(nodes_select_list);
	}
	
	function doFrame() {
		var x0 = 999999, y0 = 999999, x1 = -999999, y1 = -999999;
		
		if(ds_list_empty(nodes_select_list)) {
			if(node_focus != noone) {
				x0 = node_focus.x;
				y0 = node_focus.y;
				x1 = node_focus.x + node_focus.w;
				y1 = node_focus.y + node_focus.h;
			} else
				return;	
		} else {
			for( var i = 0; i < ds_list_size(nodes_select_list); i++ )  {
				var n = nodes_select_list[| i];
				x0 = min(x0, n.x);
				y0 = min(y0, n.y);
				x1 = max(x1, n.x + n.w);
				y1 = max(y1, n.y + n.h);
			}
		}
		
		x0 -= 64;
		y0 -= 64;
		x1 += 64;
		y1 += 64;
		
		var f = new Node_Frame(x0, y0);
		f.inputs[| 0].setValue([x1 - x0, y1 - y0]);
	}
	
	function doDelete(_merge = false) {
		if(node_focus != noone)
			nodeDelete(node_focus, _merge);
		
		for(var i = 0; i < ds_list_size(nodes_select_list); i++) {
			nodeDelete(nodes_select_list[| i], _merge);
		}
		ds_list_clear(nodes_select_list);
	}
	
	function setCurrentPreview(_node = node_focus) {
		if(!_node) return;
		
		PANEL_PREVIEW.setNodePreview(_node);
	}
	
	function setCurrentExport(_node = node_focus) {
		if(!_node) return;
		
		var _outp = -1;
		var _path = -1;
		
		for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
			if(_node.outputs[| i].type == VALUE_TYPE.path)
				_path = _node.outputs[| i];
			if(_node.outputs[| i].type == VALUE_TYPE.surface && _outp == -1)
				_outp = _node.outputs[| i];
		}
		
		if(_outp == -1) return;
		
		var _export = nodeBuild("Node_Export", _node.x + _node.w + 64, _node.y);
		if(_path != -1)
			_export.inputs[| 1].setFrom(_path);
		
		_export.inputs[| 0].setFrom(_outp);
	}
	
	function setCurrentCanvas(_node = node_focus) {
		if(!_node) return;
		
		var _outp = -1;
		var surf = -1;
		
		for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
			if(_node.outputs[| i].type == VALUE_TYPE.surface) {
				_outp = _node.outputs[| i];
				var _val = _node.outputs[| i].getValue();
				if(is_array(_val))
					surf  = _val[_node.preview_index];
				else
					surf  = _val;
				break;
			}
		}
		
		if(_outp == -1) return;
		
		var _canvas = nodeBuild("Node_Canvas", _node.x + _node.w + 64, _node.y);
		
		_canvas.inputs[| 0].setValue([surface_get_width(surf), surface_get_height(surf)]);
		var _surf = surface_clone(surf);
		_canvas.outputs[| 0].setValue(_surf);
		
		_canvas.surface_update();
	}
	
	function setCurrentCanvasBlend(_node = node_focus) {
		if(!_node) return;
		
		var _outp = -1;
		var surf = -1;
		
		for( var i = 0; i < ds_list_size(_node.outputs); i++ ) {
			if(_node.outputs[| i].type == VALUE_TYPE.surface) {
				_outp = _node.outputs[| i];
				var _val = _node.outputs[| i].getValue();
				if(is_array(_val))
					surf  = _val[_node.preview_index];
				else
					surf  = _val;
				break;
			}
		}
		
		if(_outp == -1) return;
		
		var _canvas = nodeBuild("Node_Canvas", _node.x, _node.y + _node.h + 64);
		
		_canvas.inputs[| 0].setValue([surface_get_width(surf), surface_get_height(surf)]);
		_canvas.inputs[| 5].setValue(true);
		_canvas.surface_update();
		
		var _blend = new Node_Blend(_node.x + _node.w + 64, _node.y);
		_blend.inputs[| 0].setFrom(_outp);
		_blend.inputs[| 1].setFrom(_canvas.outputs[| 0]);
	}
	
	function drawJunctionConnect() {
		if(value_dragging) {
			draw_set_color(value_color(value_dragging.type));
			
			var xx = value_dragging.x;
			var yy = value_dragging.y;
			
			switch(PREF_MAP[? "curve_connection_line"]) {
				case 0 : draw_line(xx, yy, mx, my); break;
				case 1 : draw_line_curve(xx, yy, mx, my); break;
				case 2 : draw_line_elbow(xx, yy, mx, my); break;
			}
			
			if(mouse_release(mb_left)) {
				if(value_focus && value_focus != value_dragging) {
					if(value_focus.connect_type == JUNCTION_CONNECT.input)
						value_focus.setFrom(value_dragging);
					else
						value_dragging.setFrom(value_focus);
				} else {
					if(value_dragging.connect_type == JUNCTION_CONNECT.input)
						value_dragging.removeFrom();
					value_dragging.node.triggerRender();
					
					if(value_focus != value_dragging) {
						with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8)) {	
							node_target_x = other.mouse_grid_x;
							node_target_y = other.mouse_grid_y;
							node_called   = other.value_dragging;
							
							alarm[0] = 1;
						}
					}
				}
				
				value_dragging = noone;
			}
		} else {
			if(value_focus) {
				if(mouse_press(mb_left, pFOCUS) && !key_mod_press(CTRL)) {
					value_dragging = value_focus;
				}
			}
		}
	}
	
	function callAddDialog() {
		with(dialogCall(o_dialog_add_node, mouse_mx + 8, mouse_my + 8)) {	
			node_target_x = other.mouse_grid_x;
			node_target_y = other.mouse_grid_y;
			junction_hovering = other.junction_hovering;
			
			alarm[0] = 1;
		}		
	}
	
	function drawContext() {
		draw_set_text(f_p0, fa_left, fa_center);
		var xx = ui(16), tt, tw, th;
		var bh  = toolbar_height - ui(12);
		var tbh = h - toolbar_height / 2;
		
		for(var i = -1; i < ds_list_size(node_context); i++) {
			if(i == -1) {
				tt = "Global";
			} else {
				var _cnt = node_context[| i];
				tt = _cnt.name;
			}
			
			tw = string_width(tt);
			th = string_height(tt);
			
			if(i < ds_list_size(node_context) - 1) {
				if(buttonInstant(THEME.button_hide_fill, xx - ui(6), tbh - bh / 2, tw + ui(12), bh, [mx, my], pFOCUS, pHOVER) == 2) {
					node_hover		= noone;
					node_focus		= noone;
					PANEL_PREVIEW.preview_node[0] = noone;
					PANEL_PREVIEW.preview_node[1] = noone;
					setContextFrame(true, node_context[| i + 1]);
					
					if(i == -1) {
						ds_list_clear(node_context);
						nodes_list = NODES;
						toCenterNode();
						PANEL_ANIMATION.updatePropertyList();
					} else {
						for(var j = ds_list_size(node_context) - 1; j > i; j--)
							ds_list_delete(node_context, j);
						nodes_list = node_context[| i].nodes;
						toCenterNode();
						PANEL_ANIMATION.updatePropertyList();
						break;
					}
				}
				
				draw_sprite_ui_uniform(THEME.arrow, 0, xx + tw + ui(16), tbh, 1, COLORS._main_icon);
			}
			
			draw_set_color(COLORS._main_text);
			draw_set_alpha(i < ds_list_size(node_context) - 1? 0.33 : 1);
			draw_text(xx, tbh - 2, tt);
			draw_set_alpha(1);
			xx += tw;
			xx += ui(32);
		}
	}
	
	function drawToolBar() {
		toolbar_height = ui(40);
		var ty = h - toolbar_height;
		
		if(pHOVER && point_in_rectangle(mx, my, 0, ty, w, h))
			mouse_on_graph = false;
			
		draw_set_color(COLORS.panel_toolbar_fill);
		draw_rectangle(0, ty, w, h, false);
		
		draw_set_color(COLORS.panel_toolbar_outline);
		draw_line(0, ty, w, ty);
		
		drawContext();
		
		var tbx = w - toolbar_height / 2;
		var tby = ty + toolbar_height / 2;
		
		for( var i = 0; i < array_length(toolbars); i++ ) {
			var tb = toolbars[i];
			var tbSpr = tb[0];
			var tbInd = tb[1]();
			var tbTooltip = tb[2]();
			
			var b = buttonInstant(THEME.button_hide, tbx - ui(14), tby - ui(14), ui(28), ui(28), [mx, my], pFOCUS, pHOVER, tbTooltip, tbSpr, tbInd);
			if(b == 2) tb[3]( { x: x + tbx - ui(14), y: y + tby - ui(14) } );
			
			tbx -= ui(32);
		}
		
		draw_set_color(COLORS.panel_toolbar_separator);
		draw_line_width(tbx + ui(12), tby - toolbar_height / 2 + ui(8), tbx + ui(12), tby + toolbar_height / 2 - ui(8), 2);
	}
	
	function drawMinimap() {
		var mx1 = w - ui(8);
		var my1 = h - toolbar_height - ui(8);
		var mx0 = mx1 - minimap_w;
		var my0 = my1 - minimap_h;
		
		minimap_w = min(minimap_w, w - ui(16));
		minimap_h = min(minimap_h, h - ui(16) - toolbar_height);
		
		var mini_hover = false;
		if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx1, my1)) {
			mouse_on_graph = false;
			mini_hover = true;
		}
		
		var hover = mini_hover && !point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16)) && !minimap_dragging;
		
		if(!is_surface(minimap_surface) || surface_get_width(minimap_surface) != minimap_w || surface_get_height(minimap_surface) != minimap_h) {
			minimap_surface = surface_create_valid(minimap_w, minimap_h);
		}
		
		surface_set_target(minimap_surface);
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 0.5);
		if(!ds_list_empty(nodes_list)) {
			var minx =  99999;
			var maxx = -99999;
			var miny =  99999;
			var maxy = -99999;
			
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var n = nodes_list[| i];
				minx = min(n.x - 32, minx);
				maxx = max(n.x + n.w + 32, maxx);
				
				miny = min(n.y - 32, miny);
				maxy = max(n.y + n.h + 32, maxy);
			}
			
			var cx  = (minx + maxx) / 2;
			var cy  = (miny + maxy) / 2;
			var spw = maxx - minx;
			var sph = maxy - miny;
			var ss  = min(minimap_w / spw, minimap_h / sph);
			
			draw_set_alpha(0.4);
			for(var i = 0; i < ds_list_size(nodes_list); i++) {
				var n = nodes_list[| i];
				
				var nx = minimap_w / 2 + (n.x - cx) * ss;
				var ny = minimap_h / 2 + (n.y - cy) * ss;
				var nw = n.w * ss;
				var nh = n.h * ss;
				
				draw_set_color(n.color);
				draw_roundrect_ext(nx, ny, nx + nw, ny + nh, 2, 2, false);
			}
			draw_set_alpha(1);
			
			var gx = minimap_w / 2 - (graph_x + cx) * ss;
			var gy = minimap_h / 2 - (graph_y + cy) * ss;
			var gw = w / graph_s * ss;
			var gh = h / graph_s * ss;
			
			draw_set_color(COLORS.panel_graph_minimap_focus);
			draw_rectangle(gx, gy, gx + gw, gy + gh, 1);
			
			if(minimap_panning) {
				graph_x = -((mx - mx0 - gw / 2) - minimap_w / 2) / ss - cx;
				graph_y = -((my - my0 - gh / 2) - minimap_h / 2) / ss - cy;
				if(mouse_release(mb_left))
					minimap_panning = false;
			}
			
			if(mouse_click(mb_left, hover))
				minimap_panning = true;
		}
		surface_reset_target();
		
		draw_surface_ext(minimap_surface, mx0, my0, 1, 1, 0, c_white, 0.75 + 0.25 * hover);
		draw_set_color(COLORS.panel_graph_minimap_outline);
		draw_rectangle(mx0, my0, mx1 - 1, my1 - 1, true);
		
		if(minimap_dragging) {
			mouse_on_graph = false;
			var sw = minimap_drag_sx + minimap_drag_mx - mx;
			var sh = minimap_drag_sy + minimap_drag_my - my;
			
			minimap_w = max(ui(64), sw);
			minimap_h = max(ui(64), sh);
			
			if(mouse_release(mb_left))
				minimap_dragging = false;
		}
		
		if(pHOVER && point_in_rectangle(mx, my, mx0, my0, mx0 + ui(16), my0 + ui(16))) {
			draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(2), my0 + ui(2), 1, 1, 180, c_white, 0.6);
			if(mouse_press(mb_left, pFOCUS)) {
				minimap_dragging = true;
				minimap_drag_sx = minimap_w;
				minimap_drag_sy = minimap_h;
				minimap_drag_mx = mx;
				minimap_drag_my = my;
			}
		} else 
			draw_sprite_ui(THEME.node_resize, 0, mx0 + ui(2), my0 + ui(2), 1, 1, 180, c_white, 0.3);
	}
	
	function drawContextFrame() {
		if(!context_framing) return;
		context_frame_progress = lerp_float(context_frame_progress, 1, 5);
		if(context_frame_progress == 1) 
			context_framing = false;
		
		var _s = graph_s;
		var _x = graph_x * _s;
		var _y = graph_y * _s;
		
		var _fr_x0 = 0, _fr_y0 = 0;
		var _fr_x1 = w, _fr_y1 = h;
		
		var _to_x0 = _x + context_frame_sx * _s;
		var _to_y0 = _y + context_frame_sy * _s;
		var _to_x1 = _x + context_frame_ex * _s;
		var _to_y1 = _y + context_frame_ey * _s;
		
		var prog = context_frame_direct? context_frame_progress : 1 - context_frame_progress;
		var frm_x0 = lerp(_fr_x0, _to_x0, prog);
		var frm_y0 = lerp(_fr_y0, _to_y0, prog);
		var frm_x1 = lerp(_fr_x1, _to_x1, prog);
		var frm_y1 = lerp(_fr_y1, _to_y1, prog);
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_roundrect_ext(frm_x0, frm_y0, frm_x1, frm_y1, 8, 8, true);
		draw_set_alpha(1);
	}
	
	function addContext(node) {
		recordAction(ACTION_TYPE.var_modify, self, [nodes_list, "nodes_list"]);
		recordAction(ACTION_TYPE.list_insert, node_context, [node, ds_list_size(node_context)]);
		
		nodes_list = node.nodes;
		ds_list_add(node_context, node);
		
		node_dragging = noone;
		ds_list_clear(nodes_select_list);
		selection_block = 1;
		
		toCenterNode();
		PANEL_ANIMATION.updatePropertyList();
		
		setContextFrame(false, node)
	}
	
	function setContextFrame(dirr, node) {
		context_framing = true;
		context_frame_direct   = dirr;
		context_frame_progress = 0;
		context_frame_sx = node.x;
		context_frame_sy = node.y;
		context_frame_ex = node.x + node.w;
		context_frame_ey = node.y + node.h;
	}
	
	function getCurrentContext() {
		if(ds_list_empty(node_context)) return -1;
		return node_context[| ds_list_size(node_context) - 1];
	}
	
	function getNodeList(cont = getCurrentContext()) {
		return cont == -1? NODES : cont.nodes;
	}
	
	function dropFile(path) {
		if(node_hovering && node_hovering.on_dragdrop_file != -1)
			return node_hovering.on_dragdrop_file(path);
		return false;
	}
	
	function fullView() {
		if(node_focus) {
			graph_x = -(node_focus.x + node_focus.w / 2) + w / 2 / graph_s;
			graph_y = -(node_focus.y + node_focus.h / 2) + h / 2 / graph_s;
			return;
		} 
		
		toCenterNode();
		return;
	}
	
	function drawContent(panel) {
		dragGraph();
		
		var bg = COLORS.panel_bg_clear;
		var cnt = getCurrentContext();
		var context = cnt == -1? "" : instanceof(cnt);
		switch(context) {
			case "Node_Group" :		bg = merge_color(COLORS.panel_bg_clear, COLORS.node_blend_collection, 0.05); break;
			case "Node_Iterate" :	bg = merge_color(COLORS.panel_bg_clear, COLORS.node_blend_loop, 0.05); break;
			case "Node_VFX_Group" : bg = merge_color(COLORS.panel_bg_clear, COLORS.node_blend_vfx, 0.05); break;
			case "Node_Feedback" :  bg = merge_color(COLORS.panel_bg_clear, COLORS.node_blend_feedback, 0.05); break;
		}
		draw_clear(bg);
		
		if(show_grid) drawGrid();
		
		draw_set_text(f_p0, fa_right, fa_top, COLORS._main_text_sub);
		draw_text(w - ui(8), ui(8), "x" + string(graph_s_to));
		
		drawNodes();
		drawJunctionConnect();
		drawContextFrame();
		
		mouse_on_graph = true;
		drawToolBar();
		if(minimap_show) 
			drawMinimap();
		
		if(pFOCUS) {
			if(node_focus) node_focus.focusStep();
		}
		
		if(UPDATE == RENDER_TYPE.full)
			draw_text(w - ui(8), ui(28), "Rendering...");
		else if(UPDATE == RENDER_TYPE.full)
			draw_text(w - ui(8), ui(28), "Rendering partial...");
	}
}