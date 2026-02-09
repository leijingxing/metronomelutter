import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rhythm_metronome/component/score_sheet_upload_flow.dart';
import 'package:rhythm_metronome/model/score_sheet.dart';
import 'package:rhythm_metronome/utils/global_function.dart';
import 'package:rhythm_metronome/utils/score_sheet_service.dart';

class ScoreSheetManageSheet extends StatefulWidget {
  final ScoreSheetService service;
  final String? selectedId;
  final ValueChanged<String?> onSelectionChanged;

  const ScoreSheetManageSheet({
    super.key,
    required this.service,
    required this.selectedId,
    required this.onSelectionChanged,
  });

  @override
  State<ScoreSheetManageSheet> createState() => _ScoreSheetManageSheetState();
}

class _ScoreSheetManageSheetState extends State<ScoreSheetManageSheet> {
  List<ScoreSheet> _sheets = <ScoreSheet>[];
  String? _selectedId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    final List<ScoreSheet> loaded = await widget.service.loadSheets();
    final List<ScoreSheet> valid = <ScoreSheet>[];
    bool changed = false;
    for (final ScoreSheet e in loaded) {
      final bool existsAll = e.imagePaths.isNotEmpty &&
          await Future.wait(
            e.imagePaths.map((String path) => File(path).exists()),
          ).then((List<bool> values) => values.every((bool v) => v));
      if (!existsAll) {
        changed = true;
        continue;
      }
      valid.add(e);
    }
    if (changed) {
      await widget.service.saveSheets(valid);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _sheets = valid;
      _loading = false;
      if (_selectedId != null &&
          !_sheets.any((ScoreSheet item) => item.id == _selectedId)) {
        _selectedId = null;
      }
    });
  }

  Future<void> _onAddTap() async {
    if (_saving) {
      return;
    }
    final ScoreSheetUploadResult? draft =
        await Navigator.of(context).push<ScoreSheetUploadResult>(
      MaterialPageRoute<ScoreSheetUploadResult>(
        fullscreenDialog: true,
        builder: (_) => const ScoreSheetUploadPage(),
      ),
    );
    if (draft == null) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      final ScoreSheet sheet = await widget.service.addSheet(
        name: draft.name,
        sourceImagePaths: draft.imagePaths,
      );
      final List<ScoreSheet> next = <ScoreSheet>[sheet, ..._sheets];
      await widget.service.saveSheets(next);
      if (!mounted) {
        return;
      }
      setState(() {
        _sheets = next;
      });
      $warn('谱子已保存');
    } catch (e) {
      $warn('添加失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _selectSheet(ScoreSheet sheet) async {
    _selectedId = sheet.id;
    await widget.service.saveSelectedId(sheet.id);
    widget.onSelectionChanged(sheet.id);
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _deleteSheet(ScoreSheet sheet) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('删除谱子'),
              content: Text('确定删除「${sheet.name}」吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('删除'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    final List<ScoreSheet> next =
        _sheets.where((ScoreSheet e) => e.id != sheet.id).toList();
    await widget.service.saveSheets(next);
    await widget.service.deleteSheetImages(sheet.imagePaths);
    if (_selectedId == sheet.id) {
      _selectedId = null;
      await widget.service.saveSelectedId(null);
      widget.onSelectionChanged(null);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _sheets = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '谱子列表',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _onAddTap,
                  icon: const Icon(Icons.add),
                  label: const Text('添加'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420, minHeight: 180),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _sheets.isEmpty
                      ? Center(
                          child: Text(
                            '暂无谱子，点击右上角添加',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _sheets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, int index) {
                            final ScoreSheet sheet = _sheets[index];
                            final bool active = _selectedId == sheet.id;
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _selectSheet(sheet),
                              child: Ink(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: active
                                      ? scheme.primaryContainer
                                      : (isDark
                                          ? const Color(0xFF1D2432)
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: active
                                        ? scheme.primary
                                        : scheme.outline
                                            .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(sheet.coverImagePath),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.black12,
                                            alignment: Alignment.center,
                                            child:
                                                const Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sheet.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${_formatSheetDateTime(sheet.createdAt)} · ${sheet.imagePaths.length} 页',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (active)
                                      Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.primary,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '使用中',
                                          style: TextStyle(
                                            color: scheme.onPrimary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _deleteSheet(sheet),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSheetDateTime(DateTime dt) {
    final String month = dt.month.toString().padLeft(2, '0');
    final String day = dt.day.toString().padLeft(2, '0');
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }
}
