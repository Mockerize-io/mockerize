
## Note

The design is still a WiP for this, will change (especially for when adding one under responses), need to add a label for active and add an indicator in the overview if a header is active or not (and maybe if possible indicate if it is going to override a header in an entity's parent or grand parent and vice versa)

The header widgets are completely independent of specific entity providers (routes, resposnes, servers, etc) and as such should be easy enough to introduce custom usage of any of the widgets
listed below.

## Overview of Header Widgets

- Widget Path: `lib/modules/server/widgets/header`

### header-form.widget.dart

This is the widget that gets used within other widgets/screens, it encapsulates the
crud and overview. It was based off of the design for responses.

It requires the following arguments to be passed to it to function

- headers - a list of headers
- deleteFunc - a function that is called when a header is deleted, must accept an id and return void
- saveFunc - a function that is called when a header is saved, must accept a string key, a string value, a bool indicating if it is active or not, and optionally an id (if updating)

### header-crud.widget.dart

This is the widget that contains the inputs for adding a header (key and value)

It requires the following arguments to be passed to it to function

- id - a nullable string, if not null then it will attempt to load in the header the id belongs to
- closeAction - a voidCallback, used to either close the editing overlay or modal
- saveFunc - Same type and purpose as the one passed to header-form.widget.dart
- getHeaderFunc - a function that accepts an id and returns a nullable header, header-form.widget.dart has its own function and passes it directly down, but if you're using it outside of that widget, you must provide one yourself
- getHeadersFunc - a function that returns all the headers for the current entity being edited, similar to the getHeaderFunc if you're using this widget outside of the header-form widget, you must provide the function yourself.

This can be used outside of the header-form.widget.dart and does not depend on a specific provider to function.

### header-overview.widget.dart

This is the widget that displays the list of headers for the entity, similar to the design of the response overview but without badges.

It requires the following arguments to be passed to it to function 

- header - the header that is being rendered
- deleteFunc - Same type and purpose as the one passed to header-form.widget.dart
- saveFunc - Same type and purpose as the one passed to header-form.widget.dart
- getHeaderFunc - Same type and purpose as the one passed to header-crud.widget.dart
- getHeadersFunc - Same type and purpose as the one passed to header-crud.widget.dart

This can be used outside of the header-form.widget.dart and does not depend on a specific provider to function (other than the mockerize provider for disabling the action button when in mobile)


### Misc

#### showHeaderModal

Located in `lib/modules/server/utils/show-modal.dart`, this shows the modal bottom sheet for
editing/adding a header

It requires the following arguments to be passed to it to function 

- context - BuildContext
- id - a nullable string, if not null then it will attempt to load in the header the id belongs to
- ref - RiverPod's WidgetRef, allows calling of the mockerize provider inside HeaderCrud
- saveFunc - Same type and purpose as the one passed to the above widgets
- getHeaderFunc - Same type and purpose as the one passed to the above widgets
- getHeadersFunc - Same type and purpose as the one passed to the above widgets
