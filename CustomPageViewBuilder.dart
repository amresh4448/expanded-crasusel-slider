//custome PageView Builder accept dynmic height 

import 'package:flutter/material.dart';

typedef CustomPageItemBuilder<T> = Widget Function(BuildContext context, int index, T item);

class CustomPageViewBuilder<T> extends StatefulWidget {
  final List<T> items;
  final CustomPageItemBuilder<T> itemBuilder;
  final ValueChanged<int>? onPageChanged;
  final bool allowSwipe;

  const CustomPageViewBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onPageChanged,
    this.allowSwipe = true,
  });

  @override
  State<CustomPageViewBuilder<T>> createState() => _CustomPageViewBuilderState<T>();
}

class _CustomPageViewBuilderState<T> extends State<CustomPageViewBuilder<T>> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  double _currentHeight = 0;
  late List<GlobalKey> _keys;
  Offset _dragStart = Offset.zero;
  Offset _dragUpdate = Offset.zero;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeight(_currentIndex);
    });
  }

  void _updateHeight(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (index < 0 || index >= _keys.length) return;

      final context = _keys[index].currentContext;
      if (context != null) {
        final newHeight = context.size?.height ?? 0;
        if (newHeight != _currentHeight) {
          setState(() {
            _currentHeight = newHeight;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomPageViewBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _keys = List.generate(widget.items.length, (_) => GlobalKey());
      if (_currentIndex >= widget.items.length) {
        _currentIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
      }
    }
  }

  void _goToPage(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.items.length) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = newIndex;
    });
    _updateHeight(newIndex);
    widget.onPageChanged?.call(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.allowSwipe ? (details) => _dragStart = details.globalPosition : null,
      onHorizontalDragUpdate: widget.allowSwipe ? (details) => _dragUpdate = details.globalPosition : null,
      onHorizontalDragEnd: widget.allowSwipe
          ? (details) {
              final dx = _dragUpdate.dx - _dragStart.dx;
              if (dx < -50) {
                _goToPage(_currentIndex + 1);
              } else if (dx > 50) {
                _goToPage(_currentIndex - 1);
              }
            }
          : null,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
        child: SizedBox(
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),

            transitionBuilder: (child, animation) {
              final pageIndex = (child.key as ValueKey<int>).value;
              final isForward = pageIndex > _previousIndex;

              final offsetTween = Tween<Offset>(
                begin: Offset(isForward ? 1 : -1, 0),
                end: Offset.zero,
              );

              return ClipRect(
                child: SlideTransition(
                  position: animation.drive(offsetTween),
                  child: child,
                ),
              );
             },

            child: Container(
              key: ValueKey<int>(_currentIndex),
              child: Builder(
                builder: (context) {
                  if (_currentIndex < 0 || _currentIndex >= widget.items.length) {
                    return const SizedBox();
                  }
                  final item = widget.items[_currentIndex];
                  return Container(
                    key: _keys[_currentIndex],
                    child: widget.itemBuilder(context, _currentIndex, item),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

