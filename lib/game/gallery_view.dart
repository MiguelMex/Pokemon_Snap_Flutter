import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pokeclase20263/game/gallery_repository.dart';
import 'dart:typed_data';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis capturas')),
      body: ValueListenableBuilder<List<File>>(
        valueListenable: GalleryRepository.instance.images,
        builder: (context, files, _) {
          if (files.isEmpty) {
            return const Center(child: Text('Aún no hay capturas'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columnas
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: files.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Opcional: abrir imagen en pantalla completa
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(files: files, initialIndex: index),
                    ),
                  );
                },
                child: Image.file(
                  files[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final int initialIndex;
  final List<File> files;
  const FullScreenGallery({super.key, required this.initialIndex, required this.files});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String cleanTitle(String path){
    String file = path.split('/').last;
    String name = file.split('.').first;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cleanTitle(widget.files[_currentIndex].path),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.files.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Image.file(
                      widget.files[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_,__,___) => const Icon(
                        Icons.broken_image,
                        color: Colors.black,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        )
      ),
    );
  }
}
