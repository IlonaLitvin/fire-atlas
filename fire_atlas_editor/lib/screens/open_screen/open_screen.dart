import 'package:flutter/material.dart';

import '../../store/store.dart';
import '../../store/actions/atlas_actions.dart';
import '../../store/actions/editor_actions.dart';
import '../../services/storage.dart';
import '../../widgets/icon_button.dart';
import '../../widgets/button.dart';
import '../../widgets/container.dart';
import '../../widgets/scaffold.dart';
import '../../widgets/text.dart';

import './widgets/atlas_options_container.dart';

class OpenScreen extends StatefulWidget {
  @override
  State createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {

  @override
  Widget build(_) {

    List<Widget> children = [];

    List<Widget> containerChildren = [];

    containerChildren.add(FTitle(title: 'Recent projects:'));

    final projects = FireAtlasStorage.listProjects();

    if (projects.isEmpty) {
      containerChildren.add(Center(child: FLabel(label: 'No projects created yet')));
    }

    projects.forEach((p) {
      containerChildren.add(
          Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p),
                          FIconButton(
                              iconData: Icons.folder_open,
                              onPress: () async {
                                await Store.instance.dispatchAsync(LoadAtlasAction(p));
                                Navigator.of(context).pushNamed('/editor');
                              }
                          ),
                        ],
                    ),
                    Divider(),
                  ]
              ),
          ),
      );
    });

    children.add(
        Center(child: Column(
            children: [
              // Logo of some sort
              SizedBox(height: 10),
              Container(width: 200, height: 200, color: Color(0xFFFF0000)),
              SizedBox(height: 10),
              Expanded(child: FContainer(
                      width: 400,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: containerChildren
                            ),
                            FButton(
                                label: 'New atlas',
                                onSelect: () {
                                  Store.instance.dispatch(
                                      OpenEditorModal(
                                          AtlasOptionsContainer(
                                              onConfirm: (String atlasName, int tileSize, String imageData) async {
                                                Store.instance.dispatch(CloseEditorModal());

                                                await Store.instance.dispatchAsync(
                                                    CreateAtlasAction(
                                                        id: atlasName,
                                                        imageData: imageData,
                                                        tileSize: tileSize,
                                                    ),
                                                );
                                                Navigator.of(context).pushNamed('/editor');
                                              },
                                              onCancel: () {
                                                Store.instance.dispatch(CloseEditorModal());
                                              },
                                          ),
                                          500,
                                          500,
                                      )
                                  );
                                }
                            ),
                          ]
                      ),
              )),
              SizedBox(height: 20),
            ],
        ))
    );
    return FScaffold(
        child: Stack(children: children),
    );
  }
}
