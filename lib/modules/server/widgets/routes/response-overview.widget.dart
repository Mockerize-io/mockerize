import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/core/utils/color-tools.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/providers/route-form.provider.dart';
import 'package:mockerize/modules/server/utils/show-modal.dart';
import 'package:mockerize/modules/server/widgets/routes/response-crud.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class ResponseOverview extends ConsumerStatefulWidget {
  final Response response;
  final Function callback;
  const ResponseOverview({
    super.key,
    required this.response,
    required this.callback,
  });

  @override
  ConsumerState<ResponseOverview> createState() => _ResponseOverviewState();
}

class _ResponseOverviewState extends ConsumerState<ResponseOverview> {
  bool editDetails = false;
  bool cardHovered = false;

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      // This allows us to apply hiding long text on small screens
                      width: size.contains(BreakPoint.sm)
                          ? null
                          : 90, // Does this need to be smaller depending on width? Should we do a calculation?
                      child: Text(
                        widget.response.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Badge(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 0,
                      ),
                      backgroundColor: widget.response.status.color,
                      textColor: colorScheme.onPrimary,
                      label: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              widget.response.status.code.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          size.contains(BreakPoint.lg)
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        lighten(widget.response.status.color),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                  ),
                                  child: Text(
                                    widget.response.status.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                            ),
                            child: Text(
                              widget.response.responseType.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: PopupMenuButton(
                        enabled: !editDetails,
                        onSelected: (String value) {
                          switch (value) {
                            case 'Delete':
                              // Do Something
                              ref
                                  .read(routeFormProvider.notifier)
                                  .removeResponse(widget.response.id);
                              break;
                            default:
                              showResponseModal(
                                context,
                                id: widget.response.id,
                                ref: ref,
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
              ),
              editDetails
                  ? ResponseCrud(widget.response.id, closeAction: () {
                      setState(() {
                        editDetails = false;
                      });
                    })
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
