import 'package:flutter/material.dart';

/// A wrapper around [IndexedStack] that lazily builds its children.
/// 
/// This is crucial for preventing heavy widgets (like WebViews) from initializing
/// and consuming resources (or crashing) before they are actually visible to the user.
class LazyLoadIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const LazyLoadIndexedStack({
    Key? key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  }) : super(key: key);

  @override
  State<LazyLoadIndexedStack> createState() => _LazyLoadIndexedStackState();
}

class _LazyLoadIndexedStackState extends State<LazyLoadIndexedStack> {
  late List<Widget> _activatedChildren;

  @override
  void initState() {
    super.initState();
    _activatedChildren = List.generate(
      widget.children.length,
      (i) => i == widget.index ? widget.children[i] : const SizedBox.shrink(),
    );
  }

  @override
  void didUpdateWidget(LazyLoadIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the selected index changes, activate that child if it hasn't been already
    if (widget.index != oldWidget.index) {
      if (_activatedChildren[widget.index] is SizedBox) {
        _activatedChildren[widget.index] = widget.children[widget.index];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      alignment: widget.alignment,
      textDirection: widget.textDirection,
      sizing: widget.sizing,
      children: _activatedChildren,
    );
  }
}
