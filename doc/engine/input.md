Input
=====

The input manager maps physical inputs (key presses, gamepad
sticks, etc.) to logical inputs (move horizontally, jump, and so
on).  It knows about two kinds of inputs: axes and buttons.  An
axis provides an analog value between -1 and 1 (except for
gamepad triggers which don't go below 0), while a button gives a
digital value which is either 0 or 1.

It doesn't handle text or mouse input yet.

You can bind multiple physical inputs to a single logical input
(alternate controls) and they will be combined in a sensible
way.  You can also convert between input types, binding two
buttons as a logical axis, or an axis as a logical button (using
a threshold and direction).

Overview
--------

Start the input manager with `init`, `bind` physical inputs to
logical ones, `enable` callbacks on objects, and you're good to
go.

* `Input.init()`
* `Input.bind({{name, type, dev, inp}, ...}, replace_old)`
* `Input.unbind(bindings)`
* `Input.unbind_all()`
* `Input.enable(object, raw)`
* `Input.disable(object)`
* `Input.disable_all()`
* `Input.to_physical(name) -> {{device, input}, ...}`
* `Input.to_logical(device, input) -> {name, ...}`


-----

* `Input.init()` - hook the input manager up to LÖVE's input
  callbacks.  This leaves your existing callbacks intact,
  calling them before its own.

-----

* `Input.bind(bindings, replace_old)` - `bindings` is a list of
  bindings, `replace_old` tells it whether to remove old
  bindings for the given logical inputs or to simply add to
  them.

Each binding is a list `{name, type, device, input}`:

* `name` - the name of the logical input.

* `type` - A string giving the logical input type: `axis`,
  `button`, `axis_from_buttons`, or `button_from_axis`.  Note
  that `axis_from_buttons` takes *two* `device`/`input` pairs.
  The first is the positive direction, the second the negative
  direction.  `button_from_axis` takes an optional threshold
  (always positive) and direction (1 or -1).  If not given, the
  threshold defaults to 0.5 and the direction to 1.

* `device` - the device name.  Currently supports `key`,
  `scancode`, `joystick#` (1, 2, etc.).  I haven't added mouse
  support yet.

* `input` - the button or axis within the device.  Keys and
  scancodes have the usual LÖVE names.  Joysticks have `axis#`,
  `button#`, `hat#left`, `hat#right`, `hat#up`, and `hat#down`.
  If a joystick is recognized as a gamepad, then you can also
  access its inputs by LÖVE gamepad input names.

To remove bindings you can use `Input.unbind(bindings)` or
`Input.unbind_all()`.

-----

* `Input.enable(object, raw)` - Registers an object to receive
  input callbacks.  The object *must* have an `input` method.
  By default you will get only logical inputs (`input(name,
  value, change)`).  If `raw` is true, you will get only raw
  physical events instead (`input(device, input, value)`).  To
  get both, you must call `enable` twice.

* `Input.disable(object)` - Object stops receiving input
  callbacks of any type.

* `Input.disable_all()` - Disable input callbacks for all
  objects.

-----

* `Input.to_physical(name) -> {{device, input}, ...}` - Return a
  list of the physical inputs that are bound to the named
  logical input.

* `Input.to_logical(device, input) -> {name, ...}` - Return a
  list of the logical inputs which are using the given physical
  input.


Todo
----

* Test multiple logical inputs using a single physical input.

* Test `to_logical` and `to_physical`.

* Mouse input

* Text input