# Scaffold wrap to instantiate provider
```
class ThisThingScaffold extends StatelessWidget {
  final Widget body;
  const ThisThingScaffold({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ThisChangeNotifierProvider(),
        ),
      ],
    child: body,
    );
  }
}
```

# Use provider
```
class UseTheProviderWidget extends StatelessWidget {
  const UseTheProviderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// watch / read
    final thisProvider = context.watch<ThisChangeNotifierProvider>();

    return ///
  }
}
```

# More Examples
```
class UseTheProviderWidget extends StatefulWidget {
  const UseTheProviderWidget({Key? key}) : super(key: key);

  @override
  State<UseTheProviderWidget> createState() => _UseTheProviderWidget();
}

class _UseTheProviderWidget extends State<UseTheProviderWidget> {
  void _createProviderFuture() {
    context.read<ThisChangeNotifierProvider>().addSomething('variable 1 example',8);
  }

  @override
  void initsState() {
    // _createProviderFuture(); // Issues too fast
    super.initState;
  }

  @override
  Widget build(BuildContext context) {
      final thisProvider = context.watch<ThisChangeNotifierProvider>();

      return Column(
        children: [
          OutlinedButton(onPressed: () => _createProviderFuture(), child: const Text('Add Provider thing')),
        ]
      )
  }
}
```