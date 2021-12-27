import 'package:flutter/material.dart';
import 'package:qr_ar/constants/config_constant.dart';
import 'package:qr_ar/utils/qa_text_theme.dart';
import 'package:qr_ar/widgets/qa_tap_effect.dart';

class QaCard extends StatelessWidget {
  const QaCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.background,
    required this.foreground,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData iconData;
  final Color background;
  final Color foreground;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return QaTapEffect(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ConfigConstant.margin2,
          vertical: ConfigConstant.margin2 + ConfigConstant.margin0,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: ConfigConstant.circlarRadius2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: QaTextTheme.of(context).headline6?.copyWith(color: foreground),
            ),
            ConfigConstant.sizedBoxH0,
            Text(
              subtitle,
              style: QaTextTheme.of(context).subtitle1?.copyWith(color: foreground),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.bottomRight,
              child: Icon(
                iconData,
                color: foreground,
              ),
            )
          ],
        ),
      ),
    );
  }
}
