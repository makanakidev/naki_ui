part of 'index.dart';

/// Default Naki 404 page.
class PageNotFound extends StatelessComponent {
  final String? errorTitle;
  final String? errorText;

  const PageNotFound({super.key, this.errorText, this.errorTitle});

  @override
  Component build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.height(Dim.px(30)),

          Heading(
            errorTitle ?? 'Page Not Found',
            style: const TextStyle(
              fontSize: Dim.px(40),
              textAlign: TextAlign.center,
            ),
          ),

          SubHeading(
            errorText ?? 'The page you are looking for does not exist.',
            style: TextStyle(
              fontSize: Dim.variable(
                Tokens.current.fontSize2xl.name,
                defaultValue: Tokens.current.fontSize2xl.value,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox.height(
            Dim.variable(
              Tokens.current.paddingLg.name,
              defaultValue: Tokens.current.paddingLg.value,
            ),
          ),
        ],
      ),
    );
  }
}
