import 'package:flutter/material.dart';

/// A rounded, shadowed app bar with a centered title and a left-aligned
/// back button that pops the current route.
///
/// Typical usage:
/// ```dart
/// return Scaffold(
///   appBar: const CustomAppBar(title: 'Checkout'),
///   body: ...,
/// );
/// ```
///
/// This widget implements [PreferredSizeWidget] so it can be used directly
/// in [Scaffold.appBar].
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Text displayed in the center of the app bar.
  final String title;

  /// Creates a [CustomAppBar] with the given [title].
  ///
  /// The back button automatically calls `Navigator.of(context).pop()`.
  const CustomAppBar({super.key, required this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  /// The preferred size required by [Scaffold.appBar].
  ///
  /// Uses the standard [kToolbarHeight].
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  /// Builds the decorated container + transparent [AppBar] with centered title
  /// and a custom back button on the left.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurStyle: BlurStyle.solid,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        // Keep the app bar chrome transparent; the parent container draws the look.
        forceMaterialTransparency: true,
        foregroundColor: Colors.transparent,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.arrow_back, color: Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
