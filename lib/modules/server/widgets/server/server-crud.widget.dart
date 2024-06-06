import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockerize/modules/server/utils/ip-list.dart';
import 'package:mockerize/modules/server/providers/server-form.provider.dart';
import 'package:mockerize/modules/server/providers/servers.provider.dart';
import 'package:mockerize/modules/server/utils/port-check.dart';
import 'package:mockerize/modules/server/utils/show-modal.dart';
import 'package:mockerize/modules/server/widgets/header/header-list.widget.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';
import 'package:mockerize/theme/mockerize-input.widget.dart';

class ServerCrud extends ConsumerStatefulWidget {
  final String? id;
  const ServerCrud({
    super.key,
    this.id,
  });

  @override
  ConsumerState<ServerCrud> createState() => _ServerCrudState();
}

class _ServerCrudState extends ConsumerState<ServerCrud> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final _portKey = GlobalKey<FormFieldState>();

  // bool inlineAddHeader = false;

  // void toggleInlineAddHeader() {
  //   setState(() {
  //     inlineAddHeader = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final serverForm = ref.watch(serverFormProvider);
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          MockerizeTextFormField(
                            fieldKey: _nameKey,
                            controller: serverForm.name,
                            label: 'Name',
                            hint: 'A descriptive name to identify your server.',
                          ),
                          MockerizeMarkdownFormField(
                            fieldKey: _descriptionKey,
                            controller: serverForm.description,
                            label: 'Description',
                            hint: 'Description of the server.',
                          ),
                          Flex(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            // mainAxisSize: MainAxisSize.max,
                            direction: size.contains(BreakPoint.md)
                                ? Axis.horizontal
                                : Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: FutureBuilder(
                                    initialData: const ['127.0.0.1', '0.0.0.0'],
                                    future: getAdapterIPs(),
                                    builder: (context, snapshop) {
                                      ///#region-begin Address Select
                                      return DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          label: const Text('Address'),
                                          border: const OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.2),
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        value: snapshop.connectionState ==
                                                ConnectionState.waiting
                                            ? '127.0.0.1'
                                            : serverForm.ip,
                                        hint: const Text('IP Address'),
                                        onChanged: (String? newValue) {
                                          if (snapshop.connectionState !=
                                              ConnectionState.waiting) {
                                            ref
                                                .read(
                                                    serverFormProvider.notifier)
                                                .changeAddress(newValue!);
                                          }
                                        },
                                        items: snapshop.data!
                                            .map<DropdownMenuItem<String>>(
                                                (String address) {
                                          return DropdownMenuItem<String>(
                                            value: address,
                                            child: Text(address),
                                          );
                                        }).toList(),
                                      );

                                      ///#region-end Address Select
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: size.contains(BreakPoint.md)
                                          ? 16
                                          : 0),
                                  child: MockerizeTextFormField(
                                    fieldKey: _portKey,
                                    controller: serverForm.port,
                                    label: 'Port',
                                  ),
                                ),
                              ),
                            ],
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
                                    .read(serverFormProvider.notifier)
                                    .upsertHeader,
                                headers: serverForm.headers,
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
                      headers: serverForm.headers,
                      // toggleInlineAddHeader: toggleInlineAddHeader,
                      deleteFunc:
                          ref.read(serverFormProvider.notifier).deleteHeader,
                      saveFunc:
                          ref.read(serverFormProvider.notifier).upsertHeader,
                    ),

                    ///#region-end Headers
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (GoRouterState.of(context).extra == 'home') {
                          context.go("/");
                        } else {
                          context.pop();
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                      overlayColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStatePropertyAll<Color>(
                        Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // check the port is usable first
                        if (!await canUsePort(
                            int.parse(serverForm.port.controller.value.text))) {
                          setState(() {
                            serverForm.port.error =
                                "Can't use ports between 1-1023 if not root";
                          });
                          return;
                        } else {
                          setState(() {
                            serverForm.port.error = null;
                          });
                        }

                        final result = await ref
                            .read(serversProvider.notifier)
                            .upsertServer(
                              serverForm.name.controller.value.text,
                              serverForm.ip,
                              int.parse(serverForm.port.controller.value.text),
                              description:
                                  serverForm.description.controller.value.text,
                              id: widget.id,
                              headers: serverForm.headers,
                            );
                        if (result && context.mounted) {
                          // context.push('/servers', extra: 'server');
                          // context.pop(); // TODO: where should this go?
                          if (GoRouterState.of(context).extra == 'home') {
                            context.go("/");
                          } else {
                            context.pop();
                          }
                        }
                      }
                    },
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
