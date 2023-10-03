import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/models/zone.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:barrani/widgets/form.dart';

import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SelectZone extends StatefulWidget {
  final bool isMobile;
  final PlaceZone? activeZone;
  final Function(PlaceZone) setZone;
  const SelectZone({
    Key? key,
    required this.isMobile,
    required this.activeZone,
    required this.setZone,
  }) : super(key: key);

  @override
  _SelectZoneState createState() => _SelectZoneState();
}

class _SelectZoneState extends State<SelectZone> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Row(
              children: [
                Expanded(
                  child: MyText.labelLarge('Select Zone'),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    LucideIcons.x,
                    size: 20,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 1),
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hintText: 'search',
                        prefixIcon: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            FeatherIcons.search,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                zoneList(context),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 1),
          if (!widget.isMobile)
            Padding(
              padding: MySpacing.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton.rounded(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    elevation: 0,
                    padding: MySpacing.xy(60, 16),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: MyText.labelMedium(
                      "close",
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  SizedBox zoneList(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView(
        children: zones.map((e) {
          final bool isSelected = widget.activeZone?.id == e.id;
          return InkWell(
            onTap: () {
              widget.setZone(e);
              Navigator.pop(context);
            },
            child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kColor2.withOpacity(isSelected ? 0.2 : 0),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: Text(
                    e.name,
                    textAlign: TextAlign.start,
                  ),
                )),
          );
        }).toList(),
      ),
    );
  }
}
