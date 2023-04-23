/// @var {Id.DsStack} A stack used when rendering nodes to avoid recursion.
/// @private
global.__bbmodRenderStack = ds_stack_create();

/// @func BBMOD_Node(_model)
///
/// @extends BBMOD_Class
///
/// @implements {BBMOD_IRenderable}
///
/// @desc A node struct.
///
/// @param {Struct.BBMOD_Model} _model The model which contains this node.
///
/// @see BBMOD_Model.RootNode
function BBMOD_Node(_model)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {Struct.BBMOD_Model} The model which contains this node.
	/// @readonly
	Model = _model;

	/// @var {String} The name of the node.
	/// @readonly
	Name = "";

	/// @var {Real} The node index.
	/// @readonly
	Index = 0;

	/// @var {Struct.BBMOD_Node} The parent of this node or `undefined` if it is
	/// the root node.
	/// @readonly
	Parent = undefined;

	/// @var {Bool} If `true` then the node is a bone.
	/// @readonly
	IsBone = false;

	/// @var {Bool} Set to `false` to disable rendering of the node and its
	/// child nodes.
	Visible = true;

	/// @var {Struct.BBMOD_DualQuaternion} The transformation of the node.
	/// @readonly
	Transform = new BBMOD_DualQuaternion();

	/// @var {Array<Real>} An array of mesh indices.
	/// @readonly
	Meshes = [];

	/// @var {Bool} If true then the node or a node down the chain has a mesh.
	/// @readonly
	IsRenderable = false;

	/// @var {Array<Struct.BBMOD_Node>} An array of child nodes.
	/// @see BBMOD_Node
	/// @readonly
	Children = [];

	/// @func copy(_dest)
	///
	/// @desc Copies node data into another node.
	///
	/// @param {Struct.BBMOD_Node} _dest The node to copy data to.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static copy = function (_dest) {
		_dest.Model = Model;
		_dest.Name = Name;
		_dest.Index = Index;
		_dest.Parent = Parent;
		_dest.IsBone = IsBone;
		_dest.Visible = Visible;
		_dest.Transform = Transform.Clone();
		_dest.Meshes = bbmod_array_clone(Meshes);
		_dest.IsRenderable = IsRenderable;

		for (var i = array_length(_dest.Children) - 1; i >= 0; --i)
		{
			_dest.Children[i].destroy();
		}

		_dest.Children = [];

		var i = 0;
		repeat (array_length(Children))
		{
			_dest.add_child(Children[i++].clone());
		}

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a clone of the node.
	///
	/// @return {Struct.BBMOD_Node} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Node(Model);
		copy(_clone);
		return _clone;
	};

	/// @func add_child(_node)
	///
	/// @desc Adds a child node.
	///
	/// @param {Struct.BBMOD_Node} _node The child node to add.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static add_child = function (_node) {
		gml_pragma("forceinline");
		array_push(Children, _node);
		_node.Parent = self;
		return self;
	};

	/// @func set_renderable()
	///
	/// @desc Marks the node and nodes up the chain as renderable.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static set_renderable = function () {
		gml_pragma("forceinline");
		var _current = self;
		while (_current != undefined)
		{
			//if (_current.IsRenderable)
			//{
			//	break;
			//}
			_current.IsRenderable = true;
			_current = _current.Parent;
		}
		return self;
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads node data from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the data from.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static from_buffer = function (_buffer) {
		var i;

		Name = buffer_read(_buffer, buffer_string);
		Index = buffer_read(_buffer, buffer_f32);
		IsBone = buffer_read(_buffer, buffer_bool);
		Visible = true;
		Transform = Transform.FromBuffer(_buffer, buffer_f32);

		// Meshes
		var _meshCount = buffer_read(_buffer, buffer_u32);
		var _meshes = array_create(_meshCount, undefined);
		Meshes = _meshes;

		if (_meshCount > 0)
		{
			set_renderable();
		}

		i = 0;
		repeat (_meshCount)
		{
			_meshes[@ i++] = buffer_read(_buffer, buffer_u32);
		}

		// Child nodes
		var _childCount = buffer_read(_buffer, buffer_u32);
		Children = [];

		repeat (_childCount)
		{
			var _child = new BBMOD_Node(Model);
			add_child(_child);
			_child.from_buffer(_buffer);
		}

		return self;
	};

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes node data to a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the data to.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static to_buffer = function (_buffer) {
		var i;

		buffer_write(_buffer, buffer_string, Name);
		buffer_write(_buffer, buffer_f32, Index);
		buffer_write(_buffer, buffer_bool, IsBone);
		Transform.ToBuffer(_buffer, buffer_f32);

		// Meshes
		var _meshCount = array_length(Meshes);
		buffer_write(_buffer, buffer_u32, _meshCount)

		i = 0;
		repeat (_meshCount)
		{
			 buffer_write(_buffer, buffer_u32, Meshes[i++]);
		}

		// Child nodes
		var _childCount = array_length(Children);
		buffer_write(_buffer, buffer_u32, _childCount);

		i = 0;
		repeat (_childCount)
		{
			Children[i++].to_buffer(_buffer);
		}

		return self;
	};

	/// @func submit(_materials, _transform, _batchData)
	///
	/// @desc Immediately submits the node for rendering.
	///
	/// @param {Array<Struct.BBMOD_BaseMaterial>} _materials An array of materials,
	/// one for each material slot of the model.
	/// @param {Array<Real>} _transform An array of dual quaternions for
	/// transforming animated models or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Data for dynamic
	/// batching or `undefined`.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static submit = function (_materials, _transform, _batchData) {
		var _meshes = Model.Meshes;
		var _renderStack = global.__bbmodRenderStack;
		var _node = self;

		var _matrix = matrix_get(matrix_world);
		ds_stack_push(_renderStack, _node);

		while (!ds_stack_empty(_renderStack))
		{
			_node = ds_stack_pop(_renderStack);

			if (!_node.IsRenderable || !_node.Visible)
			{
				continue;
			}

			var _nodeTransform = undefined;
			var _nodeMatrix = undefined;

			var _meshIndices = _node.Meshes;
			var _children = _node.Children;
			var i = 0;

			repeat (array_length(_meshIndices))
			{
				var _mesh = _meshes[_meshIndices[i++]];
				var _material = _materials[_mesh.MaterialIndex];

				if (_mesh.VertexFormat.Bones)
				{
					matrix_set(matrix_world, _matrix);
				}
				else
				{
					if (!_nodeTransform)
					{
						if (_transform == undefined)
						{
							_nodeTransform = _node.Transform;
						}
						else
						{
							_nodeTransform = new BBMOD_DualQuaternion()
								.FromArray(_transform, _node.Index * 8);
						}
						_nodeMatrix = matrix_multiply(_nodeTransform.ToMatrix(), _matrix);
					}

					matrix_set(matrix_world, _nodeMatrix);
				}

				_mesh.submit(_material, _transform, _batchData);
			}

			i = 0;
			repeat (array_length(_children))
			{
				ds_stack_push(_renderStack, _children[i++]);
			}
		}

		matrix_set(matrix_world, _matrix);

		return self;
	};

	/// @func render(_materials, _transform, _batchData, _matrix)
	///
	/// @desc Enqueues the node for rendering.
	///
	/// @param {Array<Struct.BBMOD_BaseMaterial>} _materials An array of materials,
	/// one for each material slot of the model.
	/// @param {Array<Real>} _transform An array of dual quaternions for
	/// transforming animated models or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} _batchData Data for dynamic
	/// batching or `undefined`.
	/// @param {Array<Real>} _matrix The current world matrix.
	///
	/// @return {Struct.BBMOD_Node} Returns `self`.
	static render = function (_materials, _transform, _batchData, _matrix) {
		var _meshes = Model.Meshes;
		var _renderStack = global.__bbmodRenderStack;
		var _node = self;

		ds_stack_push(_renderStack, _node);

		while (!ds_stack_empty(_renderStack))
		{
			_node = ds_stack_pop(_renderStack);

			if (!_node.IsRenderable || !_node.Visible)
			{
				continue;
			}

			var _nodeTransform = undefined;
			var _nodeMatrix = undefined;

			var _meshIndices = _node.Meshes;
			var _children = _node.Children;
			var i = 0;

			repeat (array_length(_meshIndices))
			{
				var _mesh = _meshes[_meshIndices[i++]];
				var _material = _materials[_mesh.MaterialIndex];

				var _meshMatrix;

				if (_mesh.VertexFormat.Bones)
				{
					_meshMatrix = _matrix;
				}
				else
				{
					if (!_nodeTransform)
					{
						if (_transform == undefined)
						{
							_nodeTransform = _node.Transform;
						}
						else
						{
							_nodeTransform = new BBMOD_DualQuaternion()
								.FromArray(_transform, _node.Index * 8);
						}
						_nodeMatrix = matrix_multiply(_nodeTransform.ToMatrix(), _matrix);
					}

					_meshMatrix = _nodeMatrix;
				}

				_mesh.render(_material, _transform, _batchData, _meshMatrix);
			}

			i = 0;
			repeat (array_length(_children))
			{
				ds_stack_push(_renderStack, _children[i++]);
			}
		}

		return self;
	};
}
