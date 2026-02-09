import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rhythm_metronome/component/about_me.dart';
import 'package:rhythm_metronome/component/change_sound.dart';
import 'package:rhythm_metronome/config/app_theme.dart';
import 'package:rhythm_metronome/store/index.dart';
import 'package:rhythm_metronome/utils/global_function.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
              _buildSwitchItem(
                context,
                title: '屏幕常亮',
                subtitle: '播放时保持屏幕不休眠',
                value: appStore.keepScreenOn,
                onChanged: (value) async {
                  appStore.setKeepScreenOn(value);
                  if (!kIsWeb) {
                    await WakelockPlus.toggle(enable: value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: '常用 BPM'),
          _SettingCard(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _presetBpms.map((bpm) {
                    return ActionChip(
                      label: Text('$bpm'),
                      onPressed: () => appStore.setBpm(bpm),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                    );
                  }).toList(),
                ),
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
                  launchURL('https://github.com/leijingxing/metronomelutter');
                },
              ),
              buildInkWellSettingItem(
                '关于',
                context,
                leading: Icons.info_outline,
                trailingText: '版本信息',
                onTap: () async {
                  final PackageInfo packageInfo =
                      await PackageInfo.fromPlatform();

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
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Text(
              '提示：主题颜色可在此切换，音效与主题设置会自动保存。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<int> _presetBpms = [
    60,
    72,
    80,
    90,
    100,
    110,
    120,
    132,
    140,
  ];

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
                  color: scheme.primary.withValues(alpha: 0.12),
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
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
              ),
            if (trailingIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  trailingIcon,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.screen_lock_portrait,
                size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
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
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4)),
          ],
        ],
      ),
    );
  }
}
