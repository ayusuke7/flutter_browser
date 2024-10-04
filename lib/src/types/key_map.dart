class KeyMap {
  bool keyUp = false;
  bool keyDown = false;
  bool keyLeft = false;
  bool keyRight = false;

  bool get anyPressed => keyUp || keyLeft || keyDown || keyRight;
}
