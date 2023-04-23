/// @func BBMOD_MeshBuilder([_primitiveType])
///
/// @extends BBMOD_Class
///
/// @desc Allows you to build meshes through code.
///
/// @param {Constant.PrimitiveType} [_primitiveType] The primitive type of built
/// meshes. Defaults to `pr_trianglelist`.
///
/// @example
/// Following code shows how you can create a plane mesh using the mesh builder.
/// ```gml
/// var _meshBuilder = new BBMOD_MeshBuilder();
/// var _vertexFormat = new BBMOD_VertexFormat(true);
/// var _v1 = new BBMOD_Vertex(_vertexFormat);
/// _v1.Position = new BBMOD_Vec3(0.0, 0.0, 0.0);
/// var _v1Ind = _meshBuilder.add_vertex(v1);
/// var _v2 = new BBMOD_Vertex(_vertexFormat);
/// _v2.Position = new BBMOD_Vec3(1.0, 0.0, 0.0);
/// var _v2Ind = _meshBuilder.add_vertex(v2);
/// var _v3 = new BBMOD_Vertex(_vertexFormat);
/// _v3.Position = new BBMOD_Vec3(1.0, 1.0, 0.0);
/// var _v3Ind = _meshBuilder.add_vertex(v3);
/// var _v4 = new BBMOD_Vertex(_vertexFormat);
/// _v4.Position = new BBMOD_Vec3(0.0, 1.0, 0.0);
/// var _v4Ind = _meshBuilder.add_vertex(v4);
/// _meshBuilder.add_face(_v1, _v2, _v4);
/// _meshBuilder.add_face(_v2, _v3, _v4);
/// var _mesh = _meshBuilder.build();
/// _meshBuilder = _meshBuilder.destroy();
/// ```
///
/// @see BBMOD_Mesh
/// @see BBMOD_Vertex
/// @see BBMOD_VertexFormat
function BBMOD_MeshBuilder(_primitiveType=pr_trianglelist)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Constant.PrimitiveType} The primitive type of built meshes.
	/// @readonly
	PrimitiveType = _primitiveType;

	/// @var {Id.DsList<Struct.BBMOD_Vertex>} List of mesh vertices.
	/// @readonly
	Vertices = ds_list_create();

	/// @var {Id.DsList<Real>} List of vertex indices that make up a face. First
	/// three indices are the first face, next three indices are the second face
	/// etc.
	/// @readonly
	Faces = ds_list_create();

	/// @func add_vertex(_vertex)
	///
	/// @desc Adds a vertex to the mesh.
	///
	/// @param {Struct.BBMOD_Vertex} _vertex The vertex to add.
	///
	/// @return {Real} Returns the index of the vertex.
	///
	/// @see BBMOD_Vertex
	static add_vertex = function (_vertex) {
		gml_pragma("forceinline");
		var _ind = ds_list_size(Vertices);
		ds_list_add(Vertices, _vertex);
		return _ind;
	};

	/// @func add_face(_index...)
	///
	/// @desc Adds a face to the mesh.
	///
	/// @param {Real} _index The index of the first vertex of the face.
	///
	/// @return {Real} Returns the index within the list of faces where
	/// the first vertex was stored.
	///
	/// @see BBMOD_MeshBuilder.Faces
	static add_face = function (_index) {
		gml_pragma("forceinline");
		var _ind = ds_list_size(Faces);
		var i = 0;
		repeat (argument_count)
		{
			ds_list_add(Faces, argument[i++]);
		}
		return _ind;
	};

	/// @func make_tangents()
	///
	/// @desc Makes tangent and bitangent vectors for added vertices.
	///
	/// @return {Struct.BBMOD_MeshBuilder} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If an error occurs during the process.
	///
	/// @note This works only for the `pr_trianglelist` primitive type!
	///
	/// @source https://gamedev.stackexchange.com/a/68617
	static make_tangents = function () {
		if (PrimitiveType != pr_trianglelist)
		{
			throw new BBMOD_Exception(
				"Cannot build tangents and bitangents for meshes with primitive"
				+ " type other than pr_trianglelist!");
		}

		var _faceCount = ds_list_size(Faces);
		var _vertexCount = ds_list_size(Vertices);
		var _tan2 = array_create(_vertexCount);

		for (var i = 0; i < _vertexCount; ++i)
		{
			Vertices[| i].TangentW = new BBMOD_Vec4(0.0);
			_tan2[@ i] = new BBMOD_Vec3(0.0);
		}

		for (var i = 0; i < _faceCount; i += 3)
		{
			var _i1 = Faces[| i];
			var _i2 = Faces[| i + 1];
			var _i3 = Faces[| i + 2];

			var _f1 = Vertices[| _i1];
			var _f2 = Vertices[| _i2];
			var _f3 = Vertices[| _i3];

			// Check if their vertex formats have the required data
			if (!(_f1.VertexFormat.Vertices && _f1.VertexFormat.Normals && _f1.VertexFormat.TextureCoords
				&& _f2.VertexFormat.Vertices && _f2.VertexFormat.Normals && _f2.VertexFormat.TextureCoords
				&& _f3.VertexFormat.Vertices && _f3.VertexFormat.Normals && _f3.VertexFormat.TextureCoords))
			{
				throw new BBMOD_Exception(
					"Vertices, normals and texture coords are required to build tangents!");
			}

			var _v1 = _f1.Position;
			var _v2 = _f2.Position;
			var _v3 = _f3.Position;

			var _w1 = _f1.TextureCoord;
			var _w2 = _f2.TextureCoord;
			var _w3 = _f3.TextureCoord;

			var _x1 = _v2.X - _v1.X;
			var _x2 = _v3.X - _v1.X;
			var _y1 = _v2.Y - _v1.Y;
			var _y2 = _v3.Y - _v1.Y;
			var _z1 = _v2.Z - _v1.Z;
			var _z2 = _v3.Z - _v1.Z;

			var _s1 = _w2.X - _w1.X;
			var _s2 = _w3.X - _w1.X;
			var _t1 = _w2.Y - _w1.Y;
			var _t2 = _w3.Y - _w1.Y;

			if (_s1 * _t2 == _t1 * _s2)
			{
				_s1 = 1.0;
				_t1 = 0.0;
				_s2 = 0.0;
				_t2 = 1.0;
			}

			var _r = 1.0 / ((_s1 * _t2) - (_s2 * _t1));
			var _temp;

			var _sdirX = ((_t2 * _x1) - (_t1 * _x2)) * _r;
			var _sdirY = ((_t2 * _y1) - (_t1 * _y2)) * _r;
			var _sdirZ = ((_t2 * _z1) - (_t1 * _z2)) * _r;

			_temp = _f1.TangentW;
			_temp.X += _sdirX;
			_temp.Y += _sdirY;
			_temp.Z += _sdirZ;

			_temp = _f2.TangentW;
			_temp.X += _sdirX;
			_temp.Y += _sdirY;
			_temp.Z += _sdirZ;

			_temp = _f3.TangentW;
			_temp.X += _sdirX;
			_temp.Y += _sdirY;
			_temp.Z += _sdirZ;

			var _tdirX = ((_s1 * _x2) - (_s2 * _x1)) * _r;
			var _tdirY = ((_s1 * _y2) - (_s2 * _y1)) * _r;
			var _tdirZ = ((_s1 * _z2) - (_s2 * _z1)) * _r;

			_temp = _tan2[_i1];
			_temp.X += _tdirX;
			_temp.Y += _tdirY;
			_temp.Z += _tdirZ;

			_temp = _tan2[_i2];
			_temp.X += _tdirX;
			_temp.Y += _tdirY;
			_temp.Z += _tdirZ;

			_temp = _tan2[_i3];
			_temp.X += _tdirX;
			_temp.Y += _tdirY;
			_temp.Z += _tdirZ;
		}

		for (var i = 0; i < _vertexCount; ++i)
		{
			var _v = Vertices[| i];
			var _n = _v.Normal;
			var _t = new BBMOD_Vec3(
				_v.TangentW.X,
				_v.TangentW.Y,
				_v.TangentW.Z
			);

			// Gram-Schmidt orthogonalize
			var _tNew = _t.Sub(_n.Scale(_n.Dot(_t))).Normalize().Copy(_v.TangentW);

			// Calculate handedness
			var _dot = _n.Cross(_tNew).Dot(_tan2[i]);
			_v.TangentW.W = (_dot < 0.0) ? -1.0 : 1.0;
		}

		return self;
	};

	/// @func build([_vertexFormat])
	///
	/// @desc Builds a mesh from the added vertices and faces.
	///
	/// @param {Struct.BBMOD_VertexFormat} [_vertexFormat] The vertex format of
	/// the mesh. This must be compatible with the format of the added vertices.
	/// If `undefined`, then the format of the first added vertex is used.
	///
	/// @return {Struct.BBMOD_Mesh} The created mesh.
	///
	/// @throws {BBMOD_Exception} If an error occurs during the mesh building
	/// process.
	///
	/// @see BBMOD_Mesh
	/// @see BBMOD_VertexFormat
	static build = function (_vertexFormat=undefined) {
		_vertexFormat ??= Vertices[| 0].VertexFormat;

		var _vbuffer = vertex_create_buffer();
		var _faceCount = ds_list_size(Faces);

		vertex_begin(_vbuffer, _vertexFormat.Raw);
		for (var i = 0; i < _faceCount; ++i)
		{
			var _ind = Faces[| i];
			var _vertex = Vertices[| _ind];
			try
			{
				_vertex.to_vertex_buffer(_vbuffer, _vertexFormat);
			}
			catch (_err)
			{
				vertex_delete_buffer(_vbuffer);
				throw _err;
			}
		}
		vertex_end(_vbuffer);

		var _mesh = new BBMOD_Mesh(_vertexFormat);
		_mesh.VertexBuffer = _vbuffer;
		_mesh.PrimitiveType = PrimitiveType;
		return _mesh;
	};

	static destroy = function () {
		Class_destroy();
		ds_list_destroy(Vertices);
		ds_list_destroy(Faces);
		return undefined;
	};
}
