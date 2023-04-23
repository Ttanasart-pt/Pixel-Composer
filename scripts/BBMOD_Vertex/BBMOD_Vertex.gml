/// @func BBMOD_Vertex(_vertexFormat)
///
/// @extends BBMOD_Class
///
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The format of the vertex.
/// This drives which properties of the vertex should be defined.
///
/// @example
/// Following code shows how the constructor fills in the vertex properties to
/// default values if they are enabled in the vertex format.
/// ```gml
/// var _vformat = new BBMOD_VertexFormat(true);
/// var _vertex = new BBMOD_Vertex(_vformat);
/// show_debug_message(_vertex.Normal); // Prints undefined
///
/// var _vformatWithNormals = new BBMOD_VertexFormat(true, true);
/// var _vertexWithNormal = new BBMOD_Vertex(_vformatWithNormals);
/// show_debug_message(_vertex.Normal); // Prints array [0, 0, 0]
/// ```
/// @see BBMOD_VertexFormat
function BBMOD_Vertex(_vertexFormat)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format. This drives which
	/// properties of the vertex should be defined.
	VertexFormat = _vertexFormat;

	/// @var {Struct.BBMOD_Vec3} The 3D position of the vertex or `undefined` if
	/// the vertex format does not have positions.
	/// @see BBMOD_VertexFormat.Vertices
	Position = VertexFormat.Vertices ? new BBMOD_Vec3() : undefined;

	/// @var {Struct.BBMOD_Vec3} The normal vector of the vertex or `undefined`
	/// if the vertex format does not have normals.
	/// @see BBMOD_VertexFormat.Normals
	Normal = VertexFormat.Normals ? BBMOD_VEC3_UP : undefined;

	/// @var {Struct.BBMOD_Vec2} The texture coordinates of the vertex or
	/// `undefined` if the vertex format does not have texture coordinates.
	/// @see BBMOD_VertexFormat.TextureCoords
	TextureCoord = VertexFormat.TextureCoords ? new BBMOD_Vec2() : undefined;

	/// @var {Real} The ARGB color of the vertex or `undefined` if the vertex
	/// format does not have colors.
	/// @see BBMOD_VertexFormat.Colors
	Color = VertexFormat.Colors ? 0 : undefined;

	/// @var {Struct.BBMOD_Vec4} The tangent vector & bitangent sign of the
	/// vertex or `undefined` if the vertex format does not have tangents &
	/// bitangents.
	/// @see BBMOD_VertexFormat.TangentW
	TangentW = VertexFormat.TangentW
		? new BBMOD_Vec4(1.0, 0.0, 0.0, 1.0)
		: undefined;

	/// @var {Struct.BBMOD_Vec4} The bone ids of the vertex or `undefined` if
	/// the vertex format does not have bones.
	/// @see BBMOD_VertexFormat.Bones
	Bones = VertexFormat.Bones ? new BBMOD_Vec4() : undefined;

	/// @var {Struct.BBMOD_Vec4} The bone weights of the vertex or `undefined`
	/// if the vertex format does not have bones.
	/// @see BBMOD_VertexFormat.Bones
	Weights = VertexFormat.Bones ? new BBMOD_Vec4() : undefined;

	/// @var {Real} The id of the model in a dynamic batch or `undefined` if the
	/// vertex format does not have ids.
	/// @see BBMOD_VertexFormat.Ids
	/// @see BBMOD_DynamicBatch
	Id = VertexFormat.Ids ? 0 : undefined;

	/// @func to_vertex_buffer(_vbuffer[, _vformat])
	///
	/// @desc Adds the vertex to the vertex buffer.
	///
	/// @param {Id.VertexBuffer} _vbuffer The vertex buffer to add the vertex to.
	/// @param {Struct.BBMOD_VertexFormat} [_vformat] The vertex format of the
	/// vertex buffer. Defaults to the format of the vertex if `undefined`.
	///
	/// @return {Struct.BBMOD_Vertex} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If the format of the vertex and the format of
	/// the buffer are not compatible.
	static to_vertex_buffer = function (_vbuffer, _vformat=undefined) {
		var _checkFormat = (_vformat == undefined);

		_vformat = _checkFormat ? VertexFormat : _vformat;

		if (_checkFormat
			&& ((_vformat.Vertices && !VertexFormat.Vertices)
			|| (_vformat.Normals && !VertexFormat.Normals)
			|| (_vformat.TextureCoords && !VertexFormat.TextureCoords)
			|| (_vformat.Colors && !VertexFormat.Colors)
			|| (_vformat.TangentW && !VertexFormat.TangentW)
			|| (_vformat.Bones && !VertexFormat.Bones)
			|| (_vformat.Ids && !VertexFormat.Ids)))
		{
			throw new BBMOD_Exception("Vertex formats are not compatible!");
		}

		if (_vformat.Vertices)
		{
			vertex_position_3d(_vbuffer, Position.X, Position.Y, Position.Z);
		}

		if (_vformat.Normals)
		{
			vertex_normal(_vbuffer, Normal.X, Normal.Y, Normal.Z);
		}

		if (_vformat.TextureCoords)
		{
			vertex_texcoord(_vbuffer, TextureCoord.X, TextureCoord.Y);
		}

		if (_vformat.Colors)
		{
			vertex_color(_vbuffer, Color & $FFFFFF, ((Color & $FF000000) >> 24) / 255.0);
		}

		if (_vformat.TangentW)
		{
			vertex_float4(_vbuffer, TangentW.X, TangentW.Y, TangentW.Z, TangentW.W);
		}

		if (_vformat.Bones)
		{
			vertex_float4(_vbuffer, Bones.X, Bones.Y, Bones.Z, Bones.W);
			vertex_float4(_vbuffer, Weights.X, Weights.Y, Weights.Z, Weights.W);
		}

		if (_vformat.Ids)
		{
			vertex_float1(_vbuffer, Id);
		}

		return self;
	};
}
