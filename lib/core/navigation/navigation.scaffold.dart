import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mockerize/core/models/mockerize_globals.model.dart';
import 'package:mockerize/core/providers/mockerize.provider.dart';
import 'package:mockerize/theme/breakpoint.widget.dart';

/// TODO: apply "shellroute" wrapper
/// Move navigation to readable object / nested array to pragmatically navigate

class MockerizeNavigationScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MockerizeNavigationScaffold(this.child, {super.key});

  @override
  ConsumerState<MockerizeNavigationScaffold> createState() =>
      _MockerizeNavigationScaffoldState();
}

class _MockerizeNavigationScaffoldState
    extends ConsumerState<MockerizeNavigationScaffold> {
  int _selectedIndex = 0;

  void calculateActiveIndex(String? currentUri) {
    // print('Run nav check [${currentUri.toString()}]');
    // if (currentUri == null) {
    //   _selectedIndex = 0;
    //   return;
    // }

    // if ((currentUri!).contains('/servers')) {
    //   _selectedIndex = 1;
    //   return;
    // }

    if ((currentUri!).contains('/settings')) {
      _selectedIndex = 1;
      return;
    }

    _selectedIndex = 0;
    return;
  }

  @override
  Widget build(BuildContext context) {
    MockerizeActionModel? mockerize = ref.watch(mockerizeProvider).globalAction;
    Uri currentUri = GoRouter.of(context).routeInformationProvider.value.uri;
    calculateActiveIndex(currentUri.toString());

    final size = mockerizeBreakSizes(context).breakPoints;

    return size.contains(BreakPoint.md)
        ? Scaffold(
            body: Row(children: [
              Card(
                color: Theme.of(context).navigationRailTheme.backgroundColor,
                surfaceTintColor:
                    Theme.of(context).navigationRailTheme.backgroundColor,
                elevation: 999,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                margin: const EdgeInsets.all(0),
                child: Container(
                  // width: 60,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Column(children: [
                    SvgPicture.asset(
                      'assets/mockerize.svg',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });

                          switch (index) {
                            case 1:
                              // context.go('/servers', extra: 'servers');
                              context.go('/settings', extra: 'settings');
                              break;
                            // case 2:
                            //   context.go('/settings', extra: 'settings');
                            //   break;
                            default:
                              context.go('/', extra: 'home');
                              break;
                          }
                        },
                        labelType: NavigationRailLabelType.selected,
                        destinations: const <NavigationRailDestination>[
                          // navigation destinations
                          NavigationRailDestination(
                            icon: Icon(Icons.dns_outlined),
                            selectedIcon: Icon(Icons.dns),
                            label: Text('Servers'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: Text('Settings'),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              Expanded(
                child: ClipRect(
                  // ClipRect to control OSX /IOS horizontal swipe dropshadow
                  child: Card(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0.0,
                    margin: const EdgeInsets.all(0.0),
                    child: widget.child,
                  ),
                ),
              ),
            ]),
          )
        : Scaffold(
            body: widget.child,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: mockerize == null
                ? const SizedBox()
                : FloatingActionButton(
                    // TODO look into why this is broken again
                    onPressed: mockerize.disabled ? null : mockerize.action,
                    tooltip: mockerize.title,
                    backgroundColor: mockerize.disabled
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).primaryColor,
                    shape: const CircleBorder(
                      side: BorderSide.none,
                    ),
                    child: Icon(
                      mockerize.icon,
                      size: 40,
                      color: mockerize.disabled
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.surface,
                    ),
                  ),
            bottomNavigationBar: BottomAppBar(
              shape:
                  mockerize == null ? null : const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                    onPressed: () => context.go('/', extra: 'home'),
                    icon: const Icon(Icons.dns_outlined),
                  ),
                  // IconButton(
                  //   color: _selectedIndex == 1
                  //       ? Theme.of(context).primaryColor
                  //       : Theme.of(context).colorScheme.onSurface,
                  //   onPressed: () => context.go('/servers', extra: 'servers'),
                  //   icon: const Icon(Icons.dns_outlined),
                  // ),
                  const SizedBox(
                    width: 50,
                  ),
                  // IconButton(
                  //   onPressed: () => context.go('/servers', extra: 'servers'),
                  //   icon: const Icon(Icons.dns_outlined),
                  // ),
                  IconButton(
                    color: _selectedIndex == 1
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                    onPressed: () => context.go('/settings', extra: 'settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            // bottomNavigationBar: BottomNavigationBar(
            //   items: const [
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.home_outlined),
            //       activeIcon: Icon(Icons.home),
            //       label: 'Home',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.dns_outlined),
            //       activeIcon: Icon(Icons.dns),
            //       label: 'Servers',
            //     ),
            //     BottomNavigationBarItem(
            //       icon: Icon(Icons.settings_outlined),
            //       activeIcon: Icon(Icons.settings),
            //       label: 'Settings',
            //     ),
            //   ],
            // showSelectedLabels: false,
            // showUnselectedLabels: false,
            // currentIndex: _selectedIndex,
            // onTap: (int index) {
            //   setState(() {
            //     _selectedIndex = index;
            //   });

            //   switch (index) {
            //     case 1:
            //       context.go('/servers');
            //       break;
            //     case 2:
            //       context.go('/settings');
            //       break;
            //     default:
            //       context.go('/');
            //       break;
            //   }
            // },
            // ),
          );
  }
}
