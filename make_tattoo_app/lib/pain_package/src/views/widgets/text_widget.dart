part of 'flutter_painter.dart';

class _TextWidget extends StatefulWidget {
  final Widget child;

  const _TextWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<_TextWidget> {
  /// The currently selected text drawable that is being edited.
  TextDrawable? selectedDrawable;
  StreamSubscription<PainterEvent>? controllerEventSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to the stream of events from the paint controller
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      controllerEventSubscription =
          PainterController.of(context).events.listen((event) {
        // When an [AddTextPainterEvent] event is received, create a new text drawable
        if (event is AddTextPainterEvent) createDrawable();
      });
    });
  }

  @override
  void dispose() {
    // Cancel subscription to events from painter controller
    controllerEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ObjectDrawableReselectedNotification>(
      onNotification: onObjectDrawableNotification,
      child: widget.child,
    );
  }

  TextSettings get settings =>
      PainterController.of(context).value.settings.text;

  bool onObjectDrawableNotification(
      ObjectDrawableReselectedNotification notification) {
    final drawable = notification.drawable;

    if (drawable is TextDrawable) {
      openTextEditor(drawable);
      // Mark notification as handled
      return true;
    }
    // Mark notification as not handled
    return false;
  }

  void createDrawable() {
    if (selectedDrawable != null) return;

    final renderBox = PainterController.of(context)
        .painterKey
        .currentContext
        ?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );

    final drawable = TextDrawable(
      text: '',
      position: center,
      style: settings.textStyle,
      hidden: true,
    );
    PainterController.of(context).addDrawables([drawable]);

    if (mounted) {
      setState(() {
        selectedDrawable = drawable;
      });
    }

    openTextEditor(drawable, true).then((value) {
      if (mounted) {
        setState(() {
          selectedDrawable = null;
        });
      }
    });
  }

  Future<void> openTextEditor(TextDrawable drawable,
      [bool isNew = false]) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => EditTextWidget(
          controller: PainterController.of(context),
          drawable: drawable,
          isNew: isNew,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }
}

class EditTextWidget extends StatefulWidget {
  final PainterController controller;

  final TextDrawable drawable;

  final bool isNew;

  const EditTextWidget({
    Key? key,
    required this.controller,
    required this.drawable,
    this.isNew = false,
  }) : super(key: key);

  @override
  EditTextWidgetState createState() => EditTextWidgetState();
}

class EditTextWidgetState extends State<EditTextWidget>
    with WidgetsBindingObserver {
  TextEditingController textEditingController = TextEditingController();
  late FocusNode textFieldNode;
  double bottomViewInsets = 0;

  TextSettings get settings => widget.controller.value.settings.text;

  bool disposed = false;

  @override
  void initState() {
    super.initState();
    textFieldNode = settings.focusNode ?? FocusNode();
    textFieldNode.addListener(focusListener);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      textFieldNode.requestFocus();
    });
    textEditingController.text = widget.drawable.text;
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    textFieldNode.removeListener(focusListener);
    if (settings.focusNode == null) textFieldNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final renderBox = widget.controller.painterKey.currentContext
        ?.findRenderObject() as RenderBox?;
    final y = renderBox?.localToGlobal(Offset.zero).dy ?? 0;
    final height = renderBox?.size.height ?? screenHeight;

    return GestureDetector(
      onTap: () => textFieldNode.unfocus(),
      child: Container(
        color: Colors.black38,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: (keyboardHeight - (screenHeight - height - y))
                  .clamp(0, screenHeight)),
          child: Center(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              cursorColor: Colors.white,
              buildCounter: buildEmptyCounter,
              maxLength: 1000,
              minLines: 1,
              maxLines: 10,
              controller: textEditingController,
              focusNode: textFieldNode,
              style: settings.textStyle,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              onEditingComplete: onEditingComplete,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance?.window.viewInsets.bottom;

    if ((value ?? bottomViewInsets) < bottomViewInsets &&
        textFieldNode.hasFocus) {
      textFieldNode.unfocus();
    }

    bottomViewInsets = value ?? 0;
  }

  void focusListener() {
    if (!mounted) return;
    if (!textFieldNode.hasFocus) {
      onEditingComplete();
    }
  }

  void onEditingComplete() {
    if (textEditingController.text.trim().isEmpty) {
      widget.controller.removeDrawable(widget.drawable);
      if (!widget.isNew) {
        DrawableDeletedNotification(widget.drawable).dispatch(context);
      }
    } else {
      final drawable = widget.drawable.copyWith(
        text: textEditingController.text.trim(),
        style: settings.textStyle,
        hidden: false,
      );
      updateDrawable(widget.drawable, drawable);
      if (widget.isNew) DrawableCreatedNotification(drawable).dispatch(context);
    }
    if (mounted && !disposed) {
      setState(() {
        disposed = true;
      });

      Navigator.pop(context);
    }
  }

  void updateDrawable(TextDrawable oldDrawable, TextDrawable newDrawable) {
    widget.controller
        .replaceDrawable(oldDrawable, newDrawable, newAction: !widget.isNew);
  }

  Widget? buildEmptyCounter(BuildContext context,
          {required int currentLength,
          int? maxLength,
          required bool isFocused}) =>
      null;
}
