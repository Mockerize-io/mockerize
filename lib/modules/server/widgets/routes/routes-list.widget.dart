import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/modules/server/providers/routers.provider.dart';

class RoutesList extends ConsumerWidget {
  final String serverId;
  const RoutesList({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(routersProvider);
    final router = ref.read(routersProvider.notifier).getByServerID(serverId)!;

    return ListView.builder(
      itemCount: router.routes.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            title: Text(router.routes[index].path),
            trailing: DropdownButton(
              value: router.routes[index].activeResponse,
              hint: const Text('Active Response'),
              onChanged: (String? newValue) {
                ref.read(routersProvider.notifier).setActiveResponse(
                      router.id,
                      router.routes[index].id,
                      newValue!,
                    );
              },
              items: router.routes[index].responses
                  .map<DropdownMenuItem<String>>((Response response) {
                return DropdownMenuItem<String>(
                  value: response.id,
                  child: Text(response.name),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
