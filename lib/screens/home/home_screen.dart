import 'package:flutter/material.dart';
import 'package:qr_ar/constants/config_constant.dart';
import 'package:qr_ar/utils/qa_color.dart';
import 'package:qr_ar/utils/qa_text_theme.dart';
import 'package:qr_ar/widgets/qa_card.dart';
import 'package:qr_ar/widgets/qa_icon_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QaColor.of(context).surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            automaticallyImplyLeading: false,
            stretch: true,
            floating: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.all(ConfigConstant.margin2),
              centerTitle: false,
              title: Text("Quick Response", style: Theme.of(context).appBarTheme.titleTextStyle),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
            actions: [
              QaIconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              )
            ],
          ),
          SliverPadding(
            padding: ConfigConstant.layoutPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ConfigConstant.sizedBoxH2,
                QaCard(
                  title: "Create QR AR",
                  subtitle: "Capture an image & convert them to QR",
                  iconData: Icons.camera,
                  background: QaColor.of(context).primary,
                  foreground: QaColor.of(context).onPrimary,
                  onTap: () {},
                ),
                ConfigConstant.sizedBoxH1,
                QaCard(
                  title: "Scan QR Code",
                  subtitle: "Scan code with 2D AR",
                  iconData: Icons.qr_code,
                  background: QaColor.of(context).secondary,
                  foreground: QaColor.of(context).onSecondary,
                  onTap: () {},
                ),
                ConfigConstant.sizedBoxH2,
                ConfigConstant.sizedBoxH2,
                Text(
                  "Recent QR",
                  style: QaTextTheme.of(context).headline6?.copyWith(color: QaColor.of(context).primary),
                ),
                ConfigConstant.sizedBoxH1,
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: ConfigConstant.circlarRadius2,
                    side: BorderSide(color: QaColor.of(context).background),
                  ),
                  tileColor: QaColor.of(context).surface,
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  title: Text(
                    "OVERLINE",
                    style: QaTextTheme.of(context).overline,
                  ),
                  subtitle: Text(
                    "Subtitle 1",
                    style: QaTextTheme.of(context).subtitle1,
                  ),
                  onTap: () {},
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
