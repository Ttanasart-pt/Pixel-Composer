/// @macro {Struct.BBMOD_VertexFormat} A vertex format useful for debugging
/// purposes, like drawing previews of colliders.
#macro BBMOD_VFORMAT_DEBUG __bbmod_vformat_debug()

/// @var {Id.VertexBuffer}
/// @private
global.__bbmodVBufferDebug = vertex_create_buffer();

function __bbmod_vformat_debug()
{
	static _vformat = new BBMOD_VertexFormat({
		Colors: true,
	});
	return _vformat;
}
