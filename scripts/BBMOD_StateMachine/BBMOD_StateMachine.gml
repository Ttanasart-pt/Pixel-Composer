/// @func BBMOD_StateMachine()
///
/// @extends BBMOD_Class
///
/// @desc A state machine.
///
/// @see BBMOD_State
function BBMOD_StateMachine()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Array<Struct.BBMOD_State>} An array of sates.
	/// @private
	__stateArray = [];

	/// @var {Bool} If `false` then the state machine has not yet entered its
	/// initial state.
	/// @readonly
	/// @see BBMOD_StateMachine.start
	Started = false;

	/// @var {Bool} If `true` then the state machine has reached its final state.
	/// @readonly
	/// @see BBMOD_StateMachine.finish
	Finished = false;

	/// @var {Struct.BBMOD_State} The current state or `undefined`.
	/// @readonly
	State = undefined;

	/// @var {Function} A function executed on the start of the state of the
	/// state machine. It should take the state machine as the first argument.
	/// Default value is `undefined`.
	OnEnter = undefined;

	/// @var {Function} A function executed in the update method *before*
	/// the current state is updated. It should take the state machine as the
	/// first argument and delta time as the second argument. Default value is
	/// `undefined`.
	OnPreUpdate = undefined;

	/// @var {Function} A function executed when the state changes. It should
	/// take the state machine as the first argument and its previous state as
	/// the second argument. Default value is `undefined`.
	OnStateChange = undefined;

	/// @var {Function} A function executed in the update method *after*
	/// the current state is updated. It should take the state machine as the
	/// first argument and delta time as the second argument. Default value is
	/// `undefined`.
	OnPostUpdate = undefined;

	/// @var {Function} A function executed on the end of the state machine.
	/// It should take the state machine as the first argument. Default value is
	/// `undefined`.
	OnExit = undefined;

	/// @func start()
	///
	/// @desc Enters the initial state of the state machine.
	///
	/// @return {Struct.BBMOD_StateMachine} Returns `self`.
	static start = function () {
		gml_pragma("forceinline");
		Started = true;
		Finished = false;
		if (OnEnter != undefined)
		{
			OnEnter(self);
		}
		return self;
	};

	/// @func finish()
	///
	/// @desc Enters the exit state of the state machine.
	///
	/// @return {Struct.BBMOD_StateMachine} Returns `self`.
	static finish = function () {
		gml_pragma("forceinline");
		Finished = true;
		if (OnExit != undefined)
		{
			OnExit(self);
		}
		return self;
	};

	/// @func add_state(_state)
	///
	/// @desc Adds a state to the state machine.
	///
	/// @param {Struct.BBMOD_State} _state The state to add.
	///
	/// @return {Struct.BBMOD_StateMachine} Returns `self`.
	static add_state = function (_state) {
		gml_pragma("forceinline");
		_state.StateMachine = self;
		array_push(__stateArray, _state);
		return self;
	};

	/// @func change_state(_state)
	///
	/// @desc Changes the state of the state machine and executes
	/// {@link BBMOD_StateMachine.OnStateChange}.
	///
	/// @param {Struct.BBMOD_State} _state The new state.
	///
	/// @return {Struct.BBMOD_StateMachine} Returns itself.
	///
	/// @throws {BBMOD_Exception} If an invalid state is passed.
	static change_state = function (_state) {
		gml_pragma("forceinline");

		// Check if the state is valid
		if (_state.StateMachine != self)
		{
			throw new BBMOD_Exception("Invalid state \"" + string(_state.Name) + "\"!");
		}

		// Exit current state
		var _statePrev = State;

		if (_statePrev != undefined)
		{
			if (_statePrev.OnExit != undefined)
			{
				_statePrev.IsActive = false;
				_statePrev.OnExit(_statePrev);
			}
		}

		// Enter new state
		State = _state;
		State.IsActive = true;
		State.__activeSince = current_time;

		if (State.OnEnter != undefined)
		{
			State.OnEnter(State);
		}

		// Trigger OnStateChange
		if (OnStateChange != undefined)
		{
			OnStateChange(self, _statePrev);
		}

		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Executes function for the current state of the state machine
	/// (if defined).
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_StateMachine} Returns `self`.
	///
	/// @note This function does not do anything if the state machine has not
	/// started yet or if it has already reached its final state.
	///
	/// @see BBMOD_StateMachine.start
	/// @see BBMOD_StateMachine.finish
	static update = function (_deltaTime) {
		gml_pragma("forceinline");

		if (!Started || Finished)
		{
			return self;
		}

		if (OnPreUpdate != undefined)
		{
			OnPreUpdate(self, _deltaTime);
		}

		if (State != undefined && State.OnUpdate != undefined)
		{
			State.OnUpdate(State);
		}

		if (OnPostUpdate != undefined)
		{
			OnPostUpdate(self, _deltaTime);
		}

		return self;
	};

	static destroy = function () {
		Class_destroy();
		for (var i = array_length(__stateArray) - 1; i >= 0; --i)
		{
			__stateArray[i].destroy();
		}
		__stateArray = [];
		return undefined;
	};
}
