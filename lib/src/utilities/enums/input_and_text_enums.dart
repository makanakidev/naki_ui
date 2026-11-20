part of 'index.dart';

/// Types of autofill suggestions for input fields.
enum Autofill {
  /// Full name.
  name('name'),

  /// Prefix or title (e.g. "Mr.", "Ms.", "Dr.", "Mlle").
  honorificPrefix('honorific-prefix'),

  /// Given name (also known as the first name).
  givenName('given-name'),

  /// Additional names (also known as middle names).
  additionalName('additional-name'),

  /// Family name (also known as the last name or surname).
  familyName('family-name'),

  /// Suffix (e.g. "Jr.", "B.Sc.", "MBASW", "II").
  honorificSuffix('honorific-suffix'),

  /// Nickname, screen name.
  nickname('nickname'),

  /// A username.
  username('username'),

  /// A new password (e.g. when creating an account
  /// or changing a password).
  newPassword('new-password'),

  /// The current password for the account identified by
  /// the username field (e.g. when logging in).
  currentPassword('current-password'),

  /// One-time code used for verifying user identity.
  oneTimeCode('one-time-code'),

  /// Job title (e.g. "Software Engineer", "Senior
  /// Vice President", "Deputy Managing Director").
  organizationTitle('organization-title'),

  /// Company name corresponding to the person,
  /// address, or contact information in the other
  /// fields associated with this field.
  organization('organization'),

  /// Street address (multiple lines, newlines preserved).
  streetAddress('street-address'),

  /// Street address (one line per field, line 1).
  addressLine1('address-line1'),

  /// Street address (one line per field, line 2).
  addressLine2('address-line2'),

  /// Street address (one line per field, line 3).
  addressLine3('address-line3'),

  /// The most fine-grained administrative level,
  /// in addresses with four administrative levels.
  addressLevel4('address-level4'),

  /// The third administrative level, in addresses
  /// with three or more administrative levels.
  addressLevel3('address-level3'),

  /// The second administrative level, in addresses with two
  /// or more administrative levels (typically city,
  /// town, or locality).
  addressLevel2('address-level2'),

  /// The broadest administrative level in the address
  /// (e.g. province, state, canton, or post town).
  addressLevel1('address-level1'),

  /// Country code.
  country('country'),

  /// Country name.
  countryName('country-name'),

  /// Postal code, post code, ZIP code, CEDEX code.
  postalCode('postal-code'),

  /// Full name as given on the payment card.
  ccName('cc-name'),

  /// Given name as given on the payment card.
  ccGivenName('cc-given-name'),

  /// Additional names given on the payment card.
  ccAdditionalName('cc-additional-name'),

  /// Family name given on the payment card.
  ccFamilyName('cc-family-name'),

  /// Code identifying the payment card
  /// (e.g. the credit card number).
  ccNumber('cc-number'),

  /// Expiration date of the payment card.
  ccExp('cc-exp'),

  /// Month component of the expiration date of the payment card.
  ccExpMonth('cc-exp-month'),

  /// Year component of the expiration date of the payment card.
  ccExpYear('cc-exp-year'),

  /// Security code for the payment card (CSC, CVC, CVV, etc.).
  ccCsc('cc-csc'),

  /// The payment card type.
  ccType('cc-type'),

  /// The currency that the user would prefer the transaction to use.
  transactionCurrency('transaction-currency'),

  /// The amount that the user would like for the transaction.
  transactionAmount('transaction-amount'),

  /// Preferred language.
  language('language'),

  /// Birthday.
  bday('bday'),

  /// Day component of birthday.
  bdayDay('bday-day'),

  /// Month component of birthday.
  bdayMonth('bday-month'),

  /// Year component of birthday.
  bdayYear('bday-year'),

  /// Gender identity.
  sex('sex'),

  /// Home page or other web page corresponding to the
  /// company, person, address, or contact information.
  url('url'),

  /// Photograph, icon, or other image corresponding to
  /// the company, person, address, or contact information.
  photo('photo'),

  /// Full telephone number, including country code.
  tel('tel'),

  /// Telephone country code.
  telCountryCode('tel-country-code'),

  /// Telephone number with country-internal prefix.
  telNational('tel-national'),

  /// Area code component of the telephone number,
  /// with a country-internal prefix applied if applicable.
  telAreaCode('tel-area-code'),

  /// Telephone number without the country code
  /// and area code components.
  telLocal('tel-local'),

  /// First part of the component of the telephone number
  /// that follows the area code, when that component is split
  /// into two components.
  telLocalPrefix('tel-local-prefix'),

  /// Last part of the component of the telephone number
  /// that follows the area code, when that component is split
  /// into two components.
  telLocalSuffix('tel-local-suffix'),

  /// Telephone number internal extension code.
  telExtension('tel-extension'),

  /// Email address.
  email('email'),

  /// URL representing an instant messaging protocol endpoint
  /// (for example, "aim:goim?screenname=example" or
  /// "xmpp:fred@example.net").
  impp('impp'),

  /// Autocomplete is disabled.
  off('off'),

  /// Autocomplete is enabled.
  on('on')
  ;

  /// The standard CSS value representing the autofill type.
  final String value;
  const Autofill(this.value);
}

/// Represents standard CSS vertical alignment baseline
/// options for inline text and components.
enum Baseline {
  /// Aligns the baseline of the element with
  /// the baseline of its parent (CSS: `baseline`).
  baseline('baseline'),

  /// Lowers the baseline of the element to
  /// the subscript position (CSS: `sub`).
  sub('sub'),

  /// Raises the baseline of the element to
  /// the superscript position (CSS: `super`).
  super_('super'),

  /// Aligns the top of the element with
  /// the top of the line (CSS: `top`).
  top('top'),

  /// Aligns the top of the element with
  /// the top of the parent font (CSS: `text-top`).
  textTop('text-top'),

  /// Aligns the middle of the element with
  /// the baseline plus half the x-height of the parent (CSS: `middle`).
  middle('middle'),

  /// Aligns the bottom of the element with
  /// the bottom of the line (CSS: `bottom`).
  bottom('bottom'),

  /// Aligns the bottom of the element with
  /// the bottom of the parent font (CSS: `text-bottom`).
  textBottom('text-bottom')
  ;

  /// The CSS value representing the vertical alignment type.
  final String value;
  const Baseline(this.value);
}
