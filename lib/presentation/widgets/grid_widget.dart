import 'package:flutter/material.dart';
import 'package:marsrover/core/utils/constants.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/rover.dart';

class GridWidget extends StatefulWidget {
  final Grid grid;
  final Rover? rover;
  final List<Rover>? history;

  const GridWidget({
    super.key,
    required this.grid,
    this.rover,
    this.history,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to rover position on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToRover();
    });
  }

  @override
  void didUpdateWidget(GridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll when rover position changes
    if (widget.rover != null && oldWidget.rover != null) {
      if (widget.rover!.position != oldWidget.rover!.position) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToRover();
        });
      }
    } else if (widget.rover != null && oldWidget.rover == null) {
      // First rover position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToRover();
      });
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _scrollToRover() {
    if (widget.rover == null) return;

    final rover = widget.rover!;

    // Calculate cell size including margin
    const cellTotalSize = AppConstants.gridCellSize + (AppConstants.gridSpacing * 2);

    // Calculate rover's position in pixels
    final roverX = (rover.position.x * cellTotalSize) + 20; // +20 for container padding
    final roverY = (rover.position.y * cellTotalSize) + 20;

    // Get viewport dimensions
    final viewportWidth = _horizontalScrollController.position.viewportDimension;
    final viewportHeight = _verticalScrollController.position.viewportDimension;

    // Calculate scroll offsets to center the rover
    final targetX = (roverX - viewportWidth / 2 + cellTotalSize / 2).clamp(
      0.0,
      _horizontalScrollController.position.maxScrollExtent,
    );

    final targetY = (roverY - viewportHeight / 2 + cellTotalSize / 2).clamp(
      0.0,
      _verticalScrollController.position.maxScrollExtent,
    );

    // Smooth scroll animation
    _horizontalScrollController.animateTo(
      targetX,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    _verticalScrollController.animateTo(
      targetY,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.grid.height,
                (y) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.grid.width,
                    (x) => _buildCell(x, y),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int x, int y) {
    final isCurrentPosition = widget.rover?.position.x == x && widget.rover?.position.y == y;
    final wasVisited = widget.history?.any(
          (r) => r.position.x == x && r.position.y == y,
        ) ??
        false;

    return Container(
      width: AppConstants.gridCellSize,
      height: AppConstants.gridCellSize,
      margin: const EdgeInsets.all(AppConstants.gridSpacing),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        color: _getCellColor(isCurrentPosition, wasVisited),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: isCurrentPosition
            ? const Icon(
                Icons.circle,
                color: Colors.white,
                size: AppConstants.roverSize,
              )
            : wasVisited
                ? Icon(
                    Icons.circle,
                    color: Colors.blue.shade200,
                    size: 12,
                  )
                : null,
      ),
    );
  }

  Color _getCellColor(bool isCurrentPosition, bool wasVisited) {
    if (isCurrentPosition) {
      return Colors.red.shade600;
    } else if (wasVisited) {
      return Colors.blue.shade50;
    } else {
      return Colors.white;
    }
  }
}
