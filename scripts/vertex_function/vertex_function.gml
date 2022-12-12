globalvar MATRIX_IDENTITY;

MATRIX_IDENTITY = matrix_build_identity();

#region format
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	global.format_pc = vertex_format_end();
#endregion

function vertex_add_pt(vertex, position, texture) {
	vertex_position_3d(vertex, position[0], position[1], position[2]);
	vertex_texcoord(vertex, texture[0], texture[1]);
}

function vertex_add_pnt(vertex, position, normal, texture) {
	vertex_position_3d(vertex, position[0], position[1], position[2]);
	vertex_normal(vertex, normal[0], normal[1], normal[2]);
	vertex_texcoord(vertex, texture[0], texture[1]);
}