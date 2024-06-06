import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/utils/show-modal.dart';
import 'package:mockerize/modules/server/widgets/header/header-crud.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class HeaderOverview extends ConsumerStatefulWidget {
  final Header header;
  final bool? noMenu;
  final Function(String id)? deleteFunc;
  final Function(String key, String value, bool active, {String? id})? saveFunc;
  final List<Header> headers;

  const HeaderOverview({
    super.key,
    required this.header,
    this.noMenu,
    required this.deleteFunc,
    required this.saveFunc,
    required this.headers,
  });

  @override
  ConsumerState<HeaderOverview> createState() => _HeaderOverviewState();
}

class _HeaderOverviewState extends ConsumerState<HeaderOverview> {
  bool editDetails = false;
  bool cardHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final colorScheme = Theme.of(context).colorScheme;
    final size = mockerizeBreakSizes(context).breakPoints;

    return MouseRegion(
      onEnter: (PointerEvent details) => setState(() {
        cardHovered = true;
      }),
      onExit: (PointerEvent details) => setState(() {
        cardHovered = false;
      }),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: cardHovered ? 8 : 0,
        surfaceTintColor: (cardHovered & editDetails == false)
            ? Theme.of(context).colorScheme.onSurface
            : const Color.fromARGB(0, 255, 255, 255),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.header.active
                          ? primaryColor
                          : colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    // This allows us to apply hiding long text on small screens
                    width: size.contains(BreakPoint.lg)
                        ? 200
                        : 150, // Does this need to be smaller depending on width? Should we do a calculation?
                    child: Text(
                      widget.header.key,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: widget.header.active
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Text(
                        widget.header.value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  widget.noMenu != null && widget.noMenu == true
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(8),
                          child: PopupMenuButton(
                            enabled: !editDetails,
                            onSelected: (String value) {
                              switch (value) {
                                case 'Delete':
                                  // Call the deletion function
                                  widget.deleteFunc!(widget.header.id);
                                  break;
                                default:
                                  showHeaderModal(
                                    context,
                                    id: widget.header.id,
                                    saveFunc: widget.saveFunc!,
                                    headers: widget.headers,
                                  );
                                  ref
                                      .read(mockerizeProvider.notifier)
                                      .setGlobalActionDisabled(true);
                                  // widget.callback(widget.response.id);
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {
                                'Edit',
                                'Delete',
                              }.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ),
                ],
              ),
              widget.noMenu != null && widget.noMenu == true
                  ? const SizedBox()
                  : editDetails
                      ? HeaderCrud(
                          widget.header.id,
                          closeAction: () {
                            setState(() {
                              editDetails = false;
                            });
                          },
                          saveFunc: widget.saveFunc!,
                          headers: widget.headers,
                        )
                      : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
