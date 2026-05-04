#region data
	global.MKBLAST_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_mkblast},
		color: function() /*=>*/ {return COLORS.node_blend_mkblast},
		// widg:  () => new mktreeBox(),
	}
	
#endregion

function Node_MK_Blast_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "MK Blast";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	is_simulation = true;
	
	seed       = 0;
	gravityDir = -90;
	dimension  = undefined;
	
	if(NODE_NEW_MANUAL) {
		var _flame   = nodeBuild("Node_MK_Blast_Flame",  x,       y, self);
		var _render  = nodeBuild("Node_MK_Blast_Render", x + 256, y, self);
		
		_render.inputs[0].setFrom(_flame.outputs[0]);
		
		addNode(_flame);
		addNode(_render);
	}
	
	////- =Inputs
	
	newInput(0, nodeValueSeed( VALUE_TYPE.integer  ));
	newInput(1, nodeValue_Rotation( "Gravity", -90 ));
	newInput(2, nodeValue_Dimension());
	
	input_display_list = [ s_MKFX, 0, 2, 
		[ "Physics", false ], 1, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ { dimension = dimension ?? inputs[2].getValue(); return dimension; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _dim = getDimension();
		var _cx  = _x + _dim[0] / 2 * _s;
		var _cy  = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my ));
	}
	
	static update = function() {
		seed       = inputs[0].getValue();
		gravityDir = inputs[1].getValue();
		dimension  = inputs[2].getValue();
	}
}

function MKBlast_Layer() constructor {
	x = 0;
	y = 0;
	colorize = undefined;
	flames   = [];
	
	static draw = function(_surf) {
		var _dim = surface_get_dimension(_surf);
		
		surface_set_target(_surf);
			BLEND_OVERRIDE
			shader_set(sh_mk_blast_clear);
				draw_empty();
			shader_reset();
			BLEND_NORMAL
			
			for( var i = 0, m = array_length(flames); i < m; i++ )
				flames[i].draw();
		surface_reset_target();
		
		if(colorize != undefined) {
			shader_set(sh_mk_blast_colorize);
			shader_set_2("dimension", _dim);
			shader_set_gradient(colorize);
		}
		
		draw_surface(_surf, 0, 0);
		
		if(colorize != undefined)
			shader_reset();
	}
	
}

function MKBlast_Element() constructor {
	x = 0; sx = 0; ex = 0;
	y = 0; sy = 0; ey = 0;
	
	life      = 0;
	lifeTotal = 0;
	lifeRatio = 0;
	
	color  = c_white;
	size   = [0,8];
	angle  = 0;
	
	speed     = 0;
	direction = 0;
	
	gravity    = 0;
	gravityDir = -90;
	friction   = 0;
	
	origin    = [0,0];
	originDim = [1,1];
	perspective = 2;
	__p = [0,0];
	
	level     = [0,1];
	
	animCurve = undefined;
	hot = true;
	
	static step = function() {}
	static draw = function(_x = 0, _y = 0, _r = 0, _s = 1) {}
}
