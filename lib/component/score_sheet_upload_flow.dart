import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rhythm_metronome/utils/global_function.dart';

class ScoreSheetUploadResult {
  final String name;
  final List<String> imagePaths;

  const ScoreSheetUploadResult({
    required this.name,
    required this.imagePaths,
  });
}

class ScoreSheetUploadPage extends StatefulWidget {
  const ScoreSheetUploadPage({super.key});

  @override
  State<ScoreSheetUploadPage> createState() => _ScoreSheetUploadPageState();
}

class _ScoreSheetUploadPageState extends State<ScoreSheetUploadPage> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedPaths = <String>[];
  String _name = '';

  bool get _canNext => _name.trim().isNotEmpty && _selectedPaths.isNotEmpty;

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }
    setState(() {
      _selectedPaths
        ..clear()
        ..addAll(picked.map((XFile e) => e.path));
    });
  }

  Future<void> _openConfirmPage() async {
    final String name = _name.trim();
    if (name.isEmpty) {
      $warn('请先填写谱子名称');
      return;
    }
    if (_selectedPaths.isEmpty) {
      $warn('请先选择图片');
      return;
    }
    final bool? confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ScoreSheetConfirmPage(
          name: name,
          imagePaths: _selectedPaths,
        ),
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(
        ScoreSheetUploadResult(
          name: name,
          imagePaths: _selectedPaths,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传谱子'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            TextField(
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: '谱子名称',
                hintText: '例如：Canon in D',
              ),
              onChanged: (String value) {
                _name = value;
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickImages,
              child: Ink(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: scheme.primaryContainer.withValues(alpha: 0.45),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_library_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedPaths.isEmpty
                            ? '选择一张或多张谱子图片'
                            : '已选择 ${_selectedPaths.length} 张图片，点击可重选',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedPaths.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedPaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (_, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedPaths[index]),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _canNext ? _openConfirmPage : null,
            child: const Text('下一步：确认'),
          ),
        ),
      ),
    );
  }
}

class ScoreSheetConfirmPage extends StatefulWidget {
  final String name;
  final List<String> imagePaths;

  const ScoreSheetConfirmPage({
    super.key,
    required this.name,
    required this.imagePaths,
  });

  @override
  State<ScoreSheetConfirmPage> createState() => _ScoreSheetConfirmPageState();
}

class _ScoreSheetConfirmPageState extends State<ScoreSheetConfirmPage> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('确认谱子'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.imagePaths.length,
                      onPageChanged: (int value) {
                        setState(() {
                          _pageIndex = value;
                        });
                      },
                      itemBuilder: (_, int index) {
                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: Image.file(
                              File(widget.imagePaths[index]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_pageIndex + 1} / ${widget.imagePaths.length}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认上传'),
          ),
        ),
      ),
    );
  }
}
