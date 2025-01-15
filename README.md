## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  customized_org_chart: 
   git:
    url:
    ref:master
```

Then run `flutter pub get` to install the package.

## Example

Here is a simple example of how to use the `customized_org_chart` package:

```dart
import 'package:flutter/material.dart';
import 'package:customized_org_chart/customized_org_chart.dart';

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {

    final orgChartController = OrgChartController<Map<dynamic, dynamic>>(
    items: [
      {"title": 'CEO', "id": '1', "to": null},
      {
        "title": 'HR Manager: John',
        "widget": Container(color: Colors.green, height: 50, width: 50),
        "id": '2',
        "to": '1',
      },
      {
        "title": 'HR Officer: Jane',
        "id": '3',
        "to": '2',
      },
      {
        "title": 'Project Manager: Test',
        "id": '4',
        "to": '1',
      },
    ],
    idProvider: (data) => data["id"],
    toProvider: (data) => data["to"],
    toSetter: (data, newID) => data["to"] = newID,
    orientation: OrgChartOrientation.topToBottom,
    spacing: 100,
  );

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: Text('Customized Org Chart Example'),
                ),
                body: OrgChart(
                controller: orgChartController,
                isDraggable: false,
                cornerRadius: 10,
                uniqueLineStyles: {
                    _uniqueNodeLine(): LineStyle(
                    color: Colors.grey,
                    strokeWidth: 3,
                    isDashed: true,
                    dashSpace: 3,
                    )
                },
                builder: (details) {
                    return Container(
                        color: Colors.red,
                        width: 100,
                        height: 100,
                        child: Column(
                            children: [
                                Text(details.item["title"]),
                                FilledButton(
                                    onPressed: () {
                                    details.hideNodes(!details.nodesHidden);
                                    },
                                    child: Text(details.nodesHidden ? "show" : "hide"),
                                )
                            ],
                        ),
                    );
                }
                ),
            ),
        );
    }

    Node<Map<dynamic, dynamic>> _uniqueNodeLine() {
    final node = orgChartController
        .getAllNodes()
        .singleWhere((e) => e.data["id"] == "4");

    return node;
  }
}
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
