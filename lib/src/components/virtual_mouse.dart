import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VirtualMouse extends StatefulWidget {
  final Widget child;
  final FocusScopeNode? node;

  final Function(Offset offset)? onClick;
  final Function(Offset, Size)? onMoveEnd;
  final Function(KeyPressed)? onKeyPressed;

  final bool autoFocus;
  final bool showCursor;

  const VirtualMouse({
    super.key,
    required this.child,
    this.node,
    this.onClick,
    this.onMoveEnd,
    this.onKeyPressed,
    this.autoFocus = true,
    this.showCursor = true,
  });

  @override
  State<VirtualMouse> createState() => _VirtualMouseState();
}

class _VirtualMouseState extends State<VirtualMouse> {
  final _keyMap = KeyPressed();

  double _dx = 0;
  double _dy = 0;

  double _maxWidth = 0;
  double _maxHeigth = 0;

  Offset get offset => Offset(_dx, _dy);
  Size get size => Size(_maxWidth, _maxHeigth);

  void _setup() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.sizeOf(context);
      setState(() {
        _dx = size.width / 2;
        _dy = size.height / 2;
      });
    });
  }

  void _move() {
    const velocity = 5.0;
    Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_keyMap.keyLeft && _dx > 0) {
        _dx -= velocity;
      } else if (_keyMap.keyRight && _dx < _maxWidth - 15) {
        _dx += velocity;
      } else if (_keyMap.keyUp && _dy > 0) {
        _dy -= velocity;
      } else if (_keyMap.keyDown && _dy < _maxHeigth) {
        _dy += velocity;
      } else {
        t.cancel();
      }

      if (widget.onMoveEnd != null) {
        widget.onMoveEnd!(offset, size);
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrants) {
        _maxWidth = constrants.maxWidth;
        _maxHeigth = constrants.maxHeight;
        return FocusScope(
          node: widget.node,
          autofocus: widget.autoFocus,
          onFocusChange: (value) {
            print("BROWSER FOCUS $value");
          },
          onKeyEvent: _keyListener,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              widget.child,
              Visibility(
                visible: widget.showCursor,
                child: Positioned(
                  top: _dy,
                  left: _dx,
                  child: Transform.rotate(
                    angle: -0.45,
                    child: const Icon(
                      Icons.navigation,
                      size: 40.0,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  KeyEventResult _keyListener(FocusNode node, KeyEvent event) {
    final pressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      event.logicalKey,
    );

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _keyMap.keyUp = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _keyMap.keyDown = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _keyMap.keyLeft = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _keyMap.keyRight = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.select) {
      if (widget.onClick != null) {
        widget.onClick!(Offset(_dx, _dy));
      }
    }

    if (_keyMap.anyPressed) {
      _move();

      if (widget.onKeyPressed != null) {
        widget.onKeyPressed!(_keyMap);
      }

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

class KeyPressed {
  bool keyUp = false;
  bool keyDown = false;
  bool keyLeft = false;
  bool keyRight = false;

  bool get anyPressed => keyUp || keyLeft || keyDown || keyRight;
}
