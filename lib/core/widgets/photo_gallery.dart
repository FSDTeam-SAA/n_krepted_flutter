import 'package:flutter/material.dart';
import 'discovery_widgets.dart';

void openPhotoGallery(
  BuildContext context,
  List<String> images, {
  int initialIndex = 0,
}) {
  if (images.isEmpty) return;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => _Gallery(images, initialIndex)),
  );
}

class _Gallery extends StatefulWidget {
  final List<String> images;
  final int initial;
  const _Gallery(this.images, this.initial);
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  late final PageController _controller;
  late int _index;
  late final List<TransformationController> _transforms;
  bool _zoomed = false;
  @override
  void initState() {
    super.initState();
    _index = widget.initial;
    _controller = PageController(initialPage: _index);
    _transforms = List.generate(
      widget.images.length,
      (_) => TransformationController(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final transform in _transforms) {
      transform.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      title: Text('${_index + 1} / ${widget.images.length}'),
      actions: [
        IconButton(
          tooltip: 'Verkleinern',
          onPressed: () => _zoom(-1),
          icon: const Icon(Icons.zoom_out),
        ),
        IconButton(
          tooltip: 'Vergrößern',
          onPressed: () => _zoom(1),
          icon: const Icon(Icons.zoom_in),
        ),
        IconButton(
          tooltip: 'Zoom zurücksetzen',
          onPressed: () => _zoom(0),
          icon: const Icon(Icons.fit_screen),
        ),
      ],
    ),
    body: PageView.builder(
      controller: _controller,
      itemCount: widget.images.length,
      physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) => setState(() {
        _transforms[_index].value = Matrix4.identity();
        _index = index;
        _zoomed = false;
      }),
      itemBuilder: (_, index) => GestureDetector(
        onDoubleTap: () => _zoom(_zoomed ? 0 : 1),
        child: InteractiveViewer(
          transformationController: _transforms[index],
          minScale: 1,
          maxScale: 5,
          onInteractionEnd: (_) => setState(
            () => _zoomed = _transforms[index].value.getMaxScaleOnAxis() > 1.01,
          ),
          child: RemotePhoto(widget.images[index], fit: BoxFit.contain),
        ),
      ),
    ),
  );

  void _zoom(int direction) {
    final scale = direction == 0
        ? 1.0
        : (_transforms[_index].value.getMaxScaleOnAxis() + direction).clamp(
            1.0,
            5.0,
          );
    final size = MediaQuery.sizeOf(context);
    _transforms[_index].value = Matrix4.identity()
      ..translateByDouble(
        size.width * (1 - scale) / 2,
        (size.height - kToolbarHeight) * (1 - scale) / 2,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
    setState(() => _zoomed = scale > 1.01);
  }
}
