import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockerize/modules/server/models/header.dart';
import 'package:mockerize/modules/server/widgets/header/header-overview.widget.dart';

class HeaderList extends ConsumerStatefulWidget {
  final List<Header> headers;
  final bool? noMenu;
  // final void Function() toggleInlineAddHeader;
  final Function(String id)? deleteFunc;
  final Function(String key, String value, bool active, {String? id})? saveFunc;
  const HeaderList({
    super.key,
    required this.headers,
    this.noMenu,
    // required this.toggleInlineAddHeader,
    this.deleteFunc,
    this.saveFunc,
  });

  @override
  ConsumerState<HeaderList> createState() => _HeaderListState();
}

class _HeaderListState extends ConsumerState<HeaderList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8,
          ),
          child: ListView.builder(
            itemCount: widget.headers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              // Used Variables with large calls
              final header = widget.headers[index];

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: HeaderOverview(
                  header: header,
                  noMenu: widget.noMenu,
                  deleteFunc: widget.deleteFunc,
                  saveFunc: widget.saveFunc,
                  headers: widget.headers,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
