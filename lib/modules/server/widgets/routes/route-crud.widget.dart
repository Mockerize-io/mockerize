import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/providers/route-form.provider.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';
import 'package:mockerize/modules/server/utils/show-modal.dart';
import 'package:mockerize/modules/server/widgets/header/header-list.widget.dart';
import 'package:mockerize/modules/server/widgets/routes/response-overview.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';

import 'response-crud.widget.dart';

class RouteCrud extends ConsumerStatefulWidget {
  final String serverId;
  final String? routeId;
  const RouteCrud(
    this.serverId, {
    super.key,
    this.routeId,
  });

  @override
  ConsumerState<RouteCrud> createState() => _RouteCrudState();
}

class _RouteCrudState extends ConsumerState<RouteCrud> {
  final _formKey = GlobalKey<FormState>();
  final _pathKey = GlobalKey<FormFieldState>();

  bool inlineAddResponse = false;

  bool inlineAddHeader = false;

  void toggleInlineAddHeader() {
    setState(() {
      inlineAddHeader = false;
    });
  }

  // @override
  @override
  Widget build(BuildContext context) {
    final routeForm = ref.watch(routeFormProvider);
    final routerID =
        ref.read(routersProvider.notifier).getByServerID(widget.serverId)!.id;
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

    void toggleInlineAddResponse() {
      setState(() {
        inlineAddResponse = false;
      });
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        right: 24,
                        bottom: 0,
                        left: 24,
                      ),
                      child: Flex(
                        direction: size.contains(BreakPoint.md)
                            ? Axis.horizontal
                            : Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: size.contains(BreakPoint.md) ? 8 : 0,
                              ),
                              child: MockerizeTextFormField(
                                fieldKey: _pathKey,
                                controller: routeForm.path,
                                label: 'Path',
                                hint: 'Request path',
                              ),
                            ),
                          ),
                          Flexible(
                            child: SizedBox(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: 40,
                                  left: size.contains(BreakPoint.md) ? 8 : 0,
                                ),
                                child: DropdownButtonFormField<Method>(
                                  decoration: InputDecoration(
                                    label: const Text('Method'),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.2),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  value: routeForm.method,
                                  // initialSelection: routeForm.method,
                                  onChanged: (Method? value) {
                                    ref
                                        .read(routeFormProvider.notifier)
                                        .setMethod(value!);
                                  },
                                  items: Method.values
                                      .map<DropdownMenuItem<Method>>(
                                          (Method value) {
                                    return DropdownMenuItem<Method>(
                                      value: value,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      // height: 65,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Headers',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showHeaderModal(
                                context,
                                saveFunc: ref
                                    .read(routeFormProvider.notifier)
                                    .upsertHeader,
                                headers: routeForm.headers,
                              );
                              // setState(() {
                              //   inlineAddHeader = !inlineAddHeader;
                              // });
                            },
                            child: const Text("Add Header"),
                          ),
                        ],
                      ),
                    ),

                    ///#region-begin Headers
                    HeaderList(
                      headers: routeForm.headers,
                      // inlineAddHeader: inlineAddHeader,
                      // toggleInlineAddHeader: toggleInlineAddHeader,
                      deleteFunc:
                          ref.read(routeFormProvider.notifier).deleteHeader,
                      saveFunc:
                          ref.read(routeFormProvider.notifier).upsertHeader,
                    ),

                    Container(
                      // height: 65,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Responses',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showResponseModal(
                                context,
                                ref: ref,
                              );
                              // ref
                              //     .read(mockerizeProvider.notifier)
                              //     .setGlobalActionDisabled(true);
                              // setState(() {
                              //   inlineAddResponse = !inlineAddResponse;
                              // });
                            },
                            child: const Text("Add Response"),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      child: Column(
                        children: [
                          inlineAddResponse
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 32,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'New Response',
                                              style: TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ResponseCrud(
                                        null,
                                        closeAction: toggleInlineAddResponse,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8,
                            ),
                            child: ListView.builder(
                              itemCount: routeForm.responses.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                // Used Variables with large calls
                                final response = routeForm.responses[index];

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 16,
                                  ),
                                  child: ResponseOverview(
                                    response: response,
                                    callback: (String value) =>
                                        showResponseModal(
                                      context,
                                      id: value,
                                      ref: ref,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ///#region-end HeaderList
            Container(
              // height: 65,
              alignment: AlignmentDirectional.bottomCenter,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: size.contains(BreakPoint.md)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.primary.withOpacity(
                            routeForm.responses.isNotEmpty ? 0.7 : 0.4),
                      ),
                      overlayColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onPressed: routeForm.responses.isNotEmpty
                        ? () async {
                            if (_formKey.currentState!.validate() &&
                                routeForm.responses.isNotEmpty) {
                              final result = await ref
                                  .read(routersProvider.notifier)
                                  .upsertRoute(
                                    routerID,
                                    ServerRoute(
                                      path:
                                          routeForm.path.controller.value.text,
                                      responses: routeForm.responses,
                                      method: routeForm.method,
                                      routeId: widget.routeId,
                                      activeResponse: routeForm.activeResponse,
                                      headers: routeForm.headers,
                                    ),
                                  );

                              if (result && context.mounted) {
                                context.pop();
                              }
                            }
                          }
                        : null,
                    child: const Text('Submit'),
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
