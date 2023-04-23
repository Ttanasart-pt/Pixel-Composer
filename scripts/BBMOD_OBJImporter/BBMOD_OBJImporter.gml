/// @func BBMOD_OBJImporter()
///
/// @extends BBMOD_Importer
///
/// @desc An `*.obj` model importer.
///
/// @example
/// ```gml
/// var _objImporter = new BBMOD_OBJImporter();
/// modHouse = _objImporter.import("Data/Assets/House.obj");
/// modTree = _objImporter.import("Data/Assets/Tree.obj");
/// modFence = _objImporter.import("Data/Assets/Fence.obj");
/// _objImporter = _objImporter.destroy();
/// ```
function BBMOD_OBJImporter()
	: BBMOD_Importer() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Importer_destroy = destroy;

	/// @var {Bool} If `true`, then Y and Z axes are switched in imported
	/// models. Default value is `false.`
	ConvertYToZUp = false;

	/// @var {Bool} If `true`, then the winding order of vertices is inverted.
	/// Default value is `false`.
	InvertWinding = false;

	__vertices = ds_list_create();

	__normals = ds_list_create();

	__textureCoords = ds_list_create();

	static can_import = function (_path) {
		return (filename_ext(_path) == ".obj");
	};

	static import = function (_path) {
		ds_list_clear(__vertices);
		ds_list_clear(__normals);
		ds_list_clear(__textureCoords);

		var _file = file_text_open_read(_path);
		if (_file == -1)
		{
			throw new BBMOD_Exception("Could not open file \"" + _path + "\"!");
		}

		var _vformat = new BBMOD_VertexFormat(true, true, true, false, true);

		var _model = new BBMOD_Model();
		_model.IsLoaded = true;
		_model.VertexFormat = _vformat;
		_model.Meshes = [];
		_model.NodeCount = 1;

		var _root = new BBMOD_Node(_model);
		_root.Name = "Node0";
		_model.RootNode = _root;

		var _meshBuilder = undefined;
		var _split = array_create(2);
		var _face = array_create(3);
		var _vertexInd = array_create(3);

		var _node = _root;
		var _material = undefined;

		while (true)
		{
			var _line = file_text_read_string(_file);
			bbmod_string_split_on_first(_line, " ", _split);
			var _keyword = _split[0];
			_line = _split[1];

			// Build mesh
			// TODO: Deduplicate code
			if (_keyword != "f" && _meshBuilder != undefined)
			{
				_meshBuilder.make_tangents();
				var _mesh = _meshBuilder.build();
				_mesh.Model = _model;

				var _meshIndex = array_length(_model.Meshes);
				array_push(_model.Meshes, _mesh);
				array_push(_node.Meshes, _meshIndex);
				_node.set_renderable();

				if (_material == undefined)
				{
					_material = 0;
					_model.MaterialCount = 1;
					array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
					array_push(_model.MaterialNames, "Material");
				}
				_mesh.MaterialIndex = _material;

				_meshBuilder = _meshBuilder.destroy();
			}

			switch (_keyword)
			{
			// Object
			case "o":
				_node = new BBMOD_Node(_model);
				_root.add_child(_node);
				_node.Index = array_length(_root.Children);
				_node.Name = "Node" + string(_node.Index);
				++_model.NodeCount;
				break;

			// Material
			case "usemtl":
				var _ind = array_length(_model.MaterialNames) - 1;
				for (/**/; _ind >= 0; --_ind)
				{
					if (_model.MaterialNames[_ind] == _line)
					{
						break;
					}
				}
				if (_ind == -1)
				{
					_ind = array_length(_model.MaterialNames);
					array_push(_model.MaterialNames, _line);
					array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
					++_model.MaterialCount;
				}
				_material = _ind;
				break;

			// Vertex
			case "v":
				bbmod_string_split_on_first(_line, " ", _split);
				var _vx = real(_split[0]);

				bbmod_string_split_on_first(_split[1], " ", _split);
				var _vy = real(_split[0]);

				bbmod_string_split_on_first(_split[1], " ", _split);
				var _vz = real(_split[0]);

				if (ConvertYToZUp)
				{
					var _temp = _vz;
					_vz = _vy;
					_vy = _temp;
				}

				ds_list_add(__vertices, _vx, _vy, _vz);
				break;

			// Normal
			case "vn":
				bbmod_string_split_on_first(_line, " ", _split);
				var _nx = real(_split[0]);

				bbmod_string_split_on_first(_split[1], " ", _split);
				var _ny = real(_split[0]);

				bbmod_string_split_on_first(_split[1], " ", _split);
				var _nz = real(_split[0]);

				if (ConvertYToZUp)
				{
					var _temp = _nz;
					_nz = _ny;
					_ny = _temp;
				}

				ds_list_add(__normals, _nx, _ny, _nz);
				break;

			// Texture
			case "vt":
				bbmod_string_split_on_first(_line, " ", _split);
				var _tx = real(_split[0]);
				if (FlipUVHorizontally)
				{
					_tx = 1.0 - _tx;
				}

				bbmod_string_split_on_first(_split[1], " ", _split);
				var _ty = real(_split[0]);
				if (FlipUVVertically)
				{
					_ty = 1.0 - _ty;
				}

				ds_list_add(__textureCoords, _tx, _ty);
				break;

			// Face
			case "f":
				if (_meshBuilder == undefined)
				{
					_meshBuilder = new BBMOD_MeshBuilder();
				}

				bbmod_string_split_on_first(_line, " ", _split);
				_face[@ 0] = _split[0];
				bbmod_string_split_on_first(_split[1], " ", _split);
				_face[@ 1] = _split[0];
				bbmod_string_split_on_first(_split[1], " ", _split);
				_face[@ 2] = _split[0];

				for (var i = 0; i < 3; ++i)
				{
					bbmod_string_split_on_first(_face[i], "/", _split);
					var _v = (real(_split[0]) - 1) * 3;

					bbmod_string_split_on_first(_split[1], "/", _split);
					var _t = (_split[0] != "")
						? (real(_split[0]) - 1) * 2
						: -1;

					bbmod_string_split_on_first(_split[1], "/", _split);
					var _n = (real(_split[0]) - 1) * 3;

					var _vertex = new BBMOD_Vertex(_vformat);
					_vertex.Position.X = __vertices[| _v];
					_vertex.Position.Y = __vertices[| _v + 1];
					_vertex.Position.Z = __vertices[| _v + 2];

					_vertex.Normal.X = __normals[| _n];
					_vertex.Normal.Y = __normals[| _n + 1];
					_vertex.Normal.Z = __normals[| _n + 2];

					if (_t != -1)
					{
						_vertex.TextureCoord.X = __textureCoords[| _t];
						_vertex.TextureCoord.Y = __textureCoords[| _t + 1];
					}

					_vertexInd[@ i] = _meshBuilder.add_vertex(_vertex);
				}

				if (InvertWinding)
				{
					_meshBuilder.add_face(_vertexInd[2], _vertexInd[1], _vertexInd[0]);
				}
				else
				{
					_meshBuilder.add_face(_vertexInd[0], _vertexInd[1], _vertexInd[2]);
				}
				break;
			}

			file_text_readln(_file);

			if (file_text_eof(_file))
			{
				break;
			}
		}

		file_text_close(_file);

		// Build mesh
		// TODO: Deduplicate code
		if (_meshBuilder != undefined)
		{
			_meshBuilder.make_tangents();
			var _mesh = _meshBuilder.build();
			_mesh.Model = _model;

			var _meshIndex = array_length(_model.Meshes);
			array_push(_model.Meshes, _mesh);
			array_push(_node.Meshes, _meshIndex);
			_node.set_renderable();

			if (_material == undefined)
			{
				_material = 0;
				_model.MaterialCount = 1;
				array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
				array_push(_model.MaterialNames, "Material");
			}
			_mesh.MaterialIndex = _material;

			_meshBuilder = _meshBuilder.destroy();
		}

		return _model;
	};

	static destroy = function () {
		Importer_destroy();
		ds_list_destroy(__vertices);
		ds_list_destroy(__normals);
		ds_list_destroy(__textureCoords);
		return undefined;
	};
}
