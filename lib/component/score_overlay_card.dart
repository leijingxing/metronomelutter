import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rhythm_metronome/model/score_sheet.dart';

/// 谱子浮层卡片，支持翻页和缩放查看谱面图片。
class ScoreOverlayCard extends StatefulWidget {
  /// 当前正在展示的谱子。
  final ScoreSheet sheet;

  /// 缩放控制器，由外部持有以便在父级同步重置状态。
  final TransformationController transformController;

  /// 关闭浮层回调。
  final Future<void> Function() onClose;

  const ScoreOverlayCard({
    super.key,
    required this.sheet,
    required this.transformController,
    required this.onClose,
  });

  @override
  State<ScoreOverlayCard> createState() => _ScoreOverlayCardState();
}

class _ScoreOverlayCardState extends State<ScoreOverlayCard> {
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant ScoreOverlayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheet.id != widget.sheet.id) {
      // 切换谱子时重置页码与缩放，避免沿用上一份谱子的浏览状态。
      _pageIndex = 0;
      widget.transformController.value = Matrix4.identity();
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF161E2B).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.sheet.imagePaths.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _pageIndex = index;
                      widget.transformController.value = Matrix4.identity();
                    });
                  },
                  itemBuilder: (_, int index) {
                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 5,
                      transformationController: widget.transformController,
                      child: Center(
                        child: Image.file(
                          File(widget.sheet.imagePaths[index]),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Text('谱子图片加载失败'),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.sheet.name}  ${_pageIndex + 1}/${widget.sheet.imagePaths.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.black.withValues(alpha: 0.24),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onClose,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
