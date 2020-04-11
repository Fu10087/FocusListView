# FocusListView

FocusListView

WebDemo: https://fu10087.github.io/FlutterProjectDemo/focuslistview/index.html#/

# usage
in pubspec.yaml
```dart
  focus_list_view:
    git:
      url: https://github.com/Fu10087/FocusListView.git
```

```dart
import 'package:focus_list_view/focus_list_view.dart';

FocusScrollController controller = FocusScrollController();

    FocusListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: 30,
      focusSize: 200,
      unFocusSize: 80,
      maxBlur: 8.0,
      reverse: false,
      itemBuilder: (context, index) {
        return Text(
            'T: $index',
            style: TextStyle(color: Colors.white, fontSize: 18)
        );
      },
      backgroundItemBuilder: (context, index) {
        return Image(
            image: NetworkImage('https://....jpg'),
            fit: BoxFit.cover);
      },
      focusOnTap: true,
      onTap: (isFocus) {
        print(isFocus);
      },
      onIndexChanged: (index) {
        setState(() {
          _fIndex = index;
        });
      },
      padding: EdgeInsets.only(left: 5, right: 5),
      itemPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      borderRadius: BorderRadius.circular(5),
      backgroundColor: Colors.transparent,
    ),
    ...
    
    controller.animateToIndex(1);
    controller.jumpToIndex(2);
```
