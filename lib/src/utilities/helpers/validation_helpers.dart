part of 'index.dart';

/// Show validation error and return true if validation error
/// is shown, otherwise return false
bool showValidationError(
  String id,
  String text, {
  bool isAutoComplete = false,
  bool isDropdown = false,
  bool isCalendar = false,
  bool isFileUploader = false,
  bool isSegmentedInput = false,
}) {
  if (kIsServer) return false;

  // remove previous validation error if present
  final validationId = '${id}_validation';
  removeValidationError(validationId);

  if (text.isEmpty) return false;

  final fieldId = id.contains('__')
      ? id
      : isAutoComplete
      ? '${id}__autocomplete'
      : isDropdown
      ? '${id}__dropdown'
      : isCalendar
      ? '${id}__calendar'
      : isFileUploader
      ? '${id}__fileuploader'
      : isSegmentedInput
      ? '${id}__segmentedfield'
      : '${id}__textfield';

  final fieldWrapper = document.getElementById(fieldId) as HTMLElement?;
  if (fieldWrapper == null) return false;

  // link input element to validation error element
  final inputElem =
      document.getElementById(isSegmentedInput ? '${id}_0' : id)
          as HTMLElement?;

  <String, String>{
    'aria-describedby': validationId,
    'aria-invalid': 'true',
  }.forEach((key, value) => inputElem?.setAttribute(key, value));

  // create validation error element
  final validationElem = document.createElement('naki-error') as HTMLElement;
  validationElem.id = validationId;
  validationElem.role = 'alert';
  validationElem.textContent = text;
  validationElem.style.cssText = {'margin-top': '8px'}.cssText;

  // place validation error as the last child of the field
  fieldWrapper.insertAdjacentElement('beforeend', validationElem);

  // scroll the field into viewport
  scrollToView(id: fieldId, useAncestor: false);

  return true;
}

/// Remove validation error from a field
void removeValidationError(String id) {
  if (kIsWeb) {
    final validationId = id.endsWith('_validation') ? id : '${id}_validation';
    document.getElementById(validationId)?.remove();

    final rawId = id.replaceAll('_validation', '');
    final targetInput =
        document.getElementById(rawId) ?? document.getElementById('${rawId}_0');

    targetInput?.removeAttribute('aria-describedby');
    targetInput?.setAttribute('aria-invalid', 'false');
  }
}

/// Clear all visible validation errors
void clearAllValidationErrors() {
  if (kIsWeb) {
    final elems = document.getElementsByTagName('naki-error');

    for (int i = elems.length - 1; i >= 0; i--) {
      final elem = elems.item(i);

      if (elem != null) {
        final rawId = elem.id.replaceAll('_validation', '');
        final targetInput =
            document.getElementById(rawId) ??
            document.getElementById('${rawId}_0');

        targetInput?.removeAttribute('aria-describedby');
        targetInput?.setAttribute('aria-invalid', 'false');

        elem.remove();
      }
    }
  }
}
