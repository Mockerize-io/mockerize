import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/widgets/header/header-crud.widget.dart';
import 'package:mockerize/modules/server/widgets/routes/response-crud.widget.dart';

void showResponseModal(BuildContext context, {String? id, WidgetRef? ref}) {
  // showModalBottomSheet(
  //   enableDrag: false,
  //   isScrollControlled: true,
  //   context: context,
  //   isDismissible: false,
  //   builder: (BuildContext context) {
  //     return ResponseCrud(
  //       id,
  //       closeAction: () => Navigator.pop(context),
  //     );
  //   },
  // ).then((_) {
  //   if (ref != null) {
  //     ref.read(mockerizeProvider.notifier).setGlobalActionDisabled(false);
  //   }
  // });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        // contentPadding: const EdgeInsets.all(0),
        child: ResponseCrud(
          id,
          closeAction: () => Navigator.pop(context),
          widgetRef: ref,
        ),
      );
    },
  ).then((_) {
    if (ref != null) {
      ref.read(mockerizeProvider.notifier).setGlobalActionDisabled(false);
    }
  });
}

void showHeaderModal(
  BuildContext context, {
  String? id,
  WidgetRef? ref,
  required Function(String key, String value, bool active, {String? id})
      saveFunc,
  required List<Header> headers,
}) {
  // showModalBottomSheet(
  //   enableDrag: false,
  //   isScrollControlled: true,
  //   context: context,
  //   isDismissible: false,
  //   builder: (BuildContext context) {
  //     return HeaderCrud(
  //       id,
  //       closeAction: () => Navigator.pop(context),
  //       saveFunc: saveFunc,
  //       headers: headers,
  //     );
  //   },
  // ).then((_) {
  //   if (ref != null) {
  //     ref.read(mockerizeProvider.notifier).setGlobalActionDisabled(false);
  //   }
  // });
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        child: HeaderCrud(
          id,
          closeAction: () => Navigator.pop(context),
          saveFunc: saveFunc,
          headers: headers,
        ),
      );
    },
  ).then((_) {
    if (ref != null) {
      ref.read(mockerizeProvider.notifier).setGlobalActionDisabled(false);
    }
  });
}
