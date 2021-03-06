import 'package:flutter/material.dart';
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

import '../../../../widgets/text.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/input_text_row.dart';

import '../../../../utils/validators.dart';
import '../../../../store/store.dart';
import '../../../../store/actions/atlas_actions.dart';
import '../../../../store/actions/editor_actions.dart';

class SelectionForm extends StatefulWidget {
  final Offset selectionStart;
  final Offset selectionEnd;

  final AnimationSelection editingSelection;

  SelectionForm({
    this.selectionStart,
    this.selectionEnd,
    this.editingSelection,
  });

  @override
  State createState() => _SelectionFormState();
}

enum SelectionType {
  SPRITE,
  ANIMATION,
}

class _SelectionFormState extends State<SelectionForm> {
  SelectionType _selectionType;

  final selectionNameController = TextEditingController();
  final frameCountController = TextEditingController();
  final stepTimeController = TextEditingController();
  bool _animationLoop = true;

  @override
  initState() {
    super.initState();

    if (widget.editingSelection != null) {
      selectionNameController.text = widget.editingSelection.id;
      frameCountController.text = widget.editingSelection.frameCount.toString();
      stepTimeController.text =
          (widget.editingSelection.stepTime * 1000).toString();

      _selectionType = SelectionType.ANIMATION;
    }
  }

  void _chooseSelectionType(SelectionType _type) {
    setState(() {
      _selectionType = _type;
    });
  }

  T _fillSelectionBaseValues<T extends Selection>(T selection) {
    final w = (widget.selectionEnd.dx - widget.selectionStart.dx).toInt();
    final h = (widget.selectionEnd.dy - widget.selectionStart.dy).toInt();

    return selection
      ..id = selectionNameController.text
      ..x = widget.selectionStart.dx.toInt()
      ..y = widget.selectionStart.dy.toInt()
      ..w = w
      ..h = h;
  }

  void _createSprite() {
    if (selectionNameController.text.isNotEmpty) {
      Store.instance.dispatch(SetSelectionAction(
          selection: _fillSelectionBaseValues(SpriteSelection())));

      Store.instance.dispatch(CloseEditorModal());
    } else {
      Store.instance.dispatch(
        CreateMessageAction(
          type: MessageType.ERROR,
          message: 'You must inform the selection name',
        ),
      );
    }
  }

  void _createAnimation() {
    if (selectionNameController.text.isNotEmpty &&
        frameCountController.text.isNotEmpty &&
        stepTimeController.text.isNotEmpty) {
      if (!isValidNumber(frameCountController.text)) {
        Store.instance.dispatch(
          CreateMessageAction(
            type: MessageType.ERROR,
            message: 'Frame count is not a valid number',
          ),
        );

        return;
      }

      if (!isValidNumber(stepTimeController.text)) {
        Store.instance.dispatch(
          CreateMessageAction(
            type: MessageType.ERROR,
            message: 'Step time is not a valid number',
          ),
        );

        return;
      }

      final selectionToSave = widget.editingSelection ??
          _fillSelectionBaseValues<AnimationSelection>(AnimationSelection());

      Store.instance.dispatch(SetSelectionAction(
          selection: selectionToSave
            ..frameCount = int.parse(frameCountController.text)
            ..stepTime = int.parse(stepTimeController.text) / 1000
            ..loop = _animationLoop));

      Store.instance.dispatch(CloseEditorModal());
    } else {
      Store.instance.dispatch(
        CreateMessageAction(
          type: MessageType.ERROR,
          message: 'All fields are required',
        ),
      );
    }
  }

  @override
  Widget build(ctx) {
    List<Widget> children = [];

    children
      ..add(SizedBox(height: 5))
      ..add(FTitle(
          title:
              '${widget.editingSelection == null ? 'New' : 'Edit'} selection item'))
      ..add(
        InputTextRow(
          label: 'Selection name:',
          inputController: selectionNameController,
          enabled: widget.editingSelection == null,
          autofocus: true,
        ),
      )
      ..add(SizedBox(height: 10));

    if (widget.editingSelection == null) {
      children
        ..add(Text('Selection type'))
        ..add(SizedBox(height: 10))
        ..add(
          Container(
              width: 200,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FButton(
                      label: 'Sprite',
                      selected: _selectionType == SelectionType.SPRITE,
                      onSelect: () =>
                          _chooseSelectionType(SelectionType.SPRITE),
                    ),
                    FButton(
                      label: 'Animation',
                      selected: _selectionType == SelectionType.ANIMATION,
                      onSelect: () =>
                          _chooseSelectionType(SelectionType.ANIMATION),
                    ),
                  ])),
        );
    }

    if (_selectionType == SelectionType.SPRITE) {
      children
        ..add(SizedBox(height: 20))
        ..add(FButton(
          label: 'Create sprite',
          onSelect: _createSprite,
        ));
    } else if (_selectionType == SelectionType.ANIMATION) {
      children
        ..add(SizedBox(height: 10))
        ..add(
          InputTextRow(
            label: 'Frame count:',
            inputController: frameCountController,
          ),
        )
        ..add(SizedBox(height: 10));

      children
        ..add(
          InputTextRow(
            label: 'Step time (in millis):',
            inputController: stepTimeController,
          ),
        )
        ..add(SizedBox(height: 20));

      children
        ..add(FLabel(label: 'Loop animation', fontSize: 12))
        ..add(Checkbox(
            value: _animationLoop,
            onChanged: (v) {
              setState(() => _animationLoop = v);
            }))
        ..add(SizedBox(height: 20));

      children.add(FButton(
        label:
            '${widget.editingSelection == null ? 'Create' : 'Save'} animation',
        onSelect: _createAnimation,
      ));
    }

    return Container(
        width: 400,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: children,
        ));
  }
}
