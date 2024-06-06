import 'package:flutter/material.dart';
import 'package:mockerize/modules/server/models/endpoint.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

class StatusSelector extends StatefulWidget {
  final Status status;
  final Function(Status) callback;
  const StatusSelector({
    super.key,
    required this.status,
    required this.callback,
  });

  @override
  State<StatusSelector> createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  final List<Status> listStatus =
      Status.values.map((status) => status).toList();

  @override
  Widget build(BuildContext context) {
    List<BreakPoint> size = mockerizeBreakSizes(context).breakPoints;

    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          left: size.contains(BreakPoint.md) ? 8 : 0,
          bottom: 40,
        ),
        child: DropdownButtonFormField<Status>(
          isExpanded: true,
          decoration: InputDecoration(
            label: const Text('Status'),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                width: 2.0,
              ),
            ),
          ),
          value: widget.status,
          selectedItemBuilder: (BuildContext context) {
            return Status.values.map((item) {
              return Container(
                width: double.maxFinite,
                margin: const EdgeInsets.only(
                  right: 12,
                ),
                child: Text(
                  '${item.code}: ${item.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          hint: const Text('Status'),
          onChanged: (Status? newValue) {
            widget.callback(newValue!);
          },
          items: listStatus.map<DropdownMenuItem<Status>>((Status status) {
            return DropdownMenuItem<Status>(
              value: status,
              child: Container(
                width: double.maxFinite,
                margin: const EdgeInsets.only(
                  right: 50,
                ),
                child: Text(
                  '${status.code}: ${status.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
