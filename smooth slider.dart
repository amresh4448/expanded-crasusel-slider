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

  // Added animation controller for smooth transition
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);
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

  void _animateToPage(int newIndex, {required bool forward}) {
    _slideController.reset();
    _slideAnimation = Tween<Offset>(
      begin: Offset(forward ? 1 : -1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _goToPage(newIndex);
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.allowSwipe ? (details) => _dragStart = details.globalPosition : null,
      onHorizontalDragUpdate: widget.allowSwipe ? (details) => _dragUpdate = details.globalPosition : null,
      onHorizontalDragEnd: widget.allowSwipe
          ? (details) {
        final dx = _dragUpdate.dx - _dragStart.dx;
        if (dx < -50 && _currentIndex < widget.items.length - 1) {
          _animateToPage(_currentIndex + 1, forward: true);
        } else if (dx > 50 && _currentIndex > 0) {
          _animateToPage(_currentIndex - 1, forward: false);
        }
      }
          : null,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
        child: SizedBox(
          width: double.infinity,
          child: SlideTransition(
            position: _slideAnimation,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
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
      ),
    );
  }
}
