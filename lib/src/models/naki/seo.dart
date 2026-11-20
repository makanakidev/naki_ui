part of 'index.dart';

/// A helper class to represent SEO tags for a page.
class SEO {
  /// Page description.
  final String? description;

  /// Keywords for search engines.
  final List<String>? keywords;

  /// SEO robots directives (e.g. ['index', 'follow']).
  final List<String>? robots;

  /// Page title (e.g. 'Home | My Awesome Site').
  final String? title;

  /// Page url (e.g. 'https://www.example.com').
  final String? url;

  /// Logo url (e.g. 'https://www.example.com/image.jpg').
  final String? logo;

  /// Page title displayed on social media platforms.
  ///
  /// When `null`, [title] will be used.
  final String? socialMediaTitle;

  /// Page description displayed on social media platforms.
  ///
  /// When `null`, [description] will be used.
  final String? socialMediaDescription;

  /// Image displayed on social media platforms.
  ///
  /// When `null`, [logo] will be used if provided.
  final String? socialMediaBanner;

  const SEO({
    this.description,
    this.keywords,
    this.robots,
    this.title,
    this.url,
    this.logo,
    this.socialMediaTitle,
    this.socialMediaDescription,
    this.socialMediaBanner,
  });
}
