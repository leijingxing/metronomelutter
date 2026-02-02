import 'package:flutter/material.dart';
import 'package:metronomelutter/component/about_me.dart';
import 'package:metronomelutter/component/change_sound.dart';
import 'package:metronomelutter/config/app_theme.dart';
import 'package:metronomelutter/store/index.dart';
import 'package:metronomelutter/utils/global_function.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _SectionHeader(title: '功能'),
          _SettingCard(
            children: [
              buildInkWellSettingItem(
                '音效',
                context,
                leading: Icons.music_note,
                trailingText: '点击选择',
                onTap: () async {
                  final res = await changeSound(context);
                  if (res != null) {
                    appStore.setSoundType(res);
                  }
                },
              ),
              buildInkWellSettingItem(
                '主题',
                context,
                leading: Icons.color_lens,
                trailingText: '切换配色',
                onTap: () async {
                  final res = await _changeTheme(context);
                  if (res != null) {
                    appStore.setThemeIndex(res);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: '信息'),
          _SettingCard(
            children: [
              buildInkWellSettingItem(
                '源码',
                context,
                leading: Icons.code,
                trailingIcon: Icons.open_in_new,
                onTap: () async {
                  launchURL('https://github.com/Tyrone2333/metronomelutter');
                },
              ),
              buildInkWellSettingItem(
                '关于',
                context,
                leading: Icons.info_outline,
                trailingText: '版本信息',
                onTap: () async {
                  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

                  final String appName = packageInfo.appName;
                  final String packageName = packageInfo.packageName;
                  final String version = packageInfo.version;
                  final String buildNumber = packageInfo.buildNumber;
                  print(
                      '正在检查版本: ---$appName---$packageName---$version---$buildNumber---');

                  showDialog(
                    context: context,
                    builder: (ctx) =>
                        AboutMe(version: 'v$version+$buildNumber'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
            ),
            child: Text(
              '提示：主题颜色可在此切换，音效与主题设置会自动保存。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.65),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInkWellSettingItem(
    String text,
    BuildContext context, {
    final VoidCallback? onTap,
    IconData? leading,
    String? trailingText,
    IconData? trailingIcon,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          children: [
            if (leading != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(leading, size: 20, color: scheme.primary),
              ),
            if (leading != null) const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.55),
                    ),
              ),
            if (trailingIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  trailingIcon,
                  size: 18,
                  color: scheme.onSurface.withOpacity(0.55),
                ),
              ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Future<int?> _changeTheme(BuildContext context) async {
    Widget buildOpt(String name, int val) {
      return SimpleDialogOption(
        onPressed: () => Navigator.pop(context, val),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(name),
        ),
      );
    }

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('选择主题'),
          children: AppThemes.all
              .asMap()
              .entries
              .map((entry) => buildOpt(entry.value.name, entry.key))
              .toList(),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: scheme.outlineVariant.withOpacity(0.4)),
          ],
        ],
      ),
    );
  }
}
