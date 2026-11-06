import 'package:jaspr/dom.dart' hide AspectRatio, Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

const _tileColors = [
  Color('#2563eb'),
  Color('#0d9488'),
  Color('#d97706'),
  Color('#db2777'),
  Color('#7c3aed'),
  Color('#059669'),
];

const _pins = [
  (title: 'Everyday leather boots', author: 'Ama Boateng', height: 240.0),
  (title: 'Vintage Continental', author: 'Leo Martin', height: 170.0),
  (title: 'Morning desk notes', author: 'Priya Nair', height: 210.0),
  (title: 'Clean studio setup', author: 'Noah Kim', height: 280.0),
  (title: 'Misty mountain ridge', author: 'Sofia Rossi', height: 150.0),
  (title: 'Dune grass at the shore', author: 'Kofi Mensah', height: 230.0),
  (title: 'Street walks', author: 'Mina Park', height: 190.0),
  (title: 'Beach day finds', author: 'Eli Cohen', height: 260.0),
];

/// The layout and scrolling groups.
class LayoutPage extends StatelessComponent {
  const LayoutPage({super.key});

  Gradient get _aurora => Gradient()
    ..applyLinear(
      colors: const [
        Color('#7c3aed'),
        Color('#2563eb'),
        Color('#06b6d4'),
        Color('#f59e0b'),
      ],
      direction: LinearGradientDirection.toBottomRight,
    );

  Component _tile(int index, {Dim? height}) {
    return Container(
      height: height,
      width: const Dim.percent(100),
      decoration: BoxDecoration(
        backgroundColor: _tileColors[index % _tileColors.length],
        borderRadius: BorderRadiusData.all(const Dim.px(8)),
        padding: const EdgeInsets.all(Dim.px(12)),
        clip: true,
      ),
      child: NakiText(
        'Tile ${index + 1}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Component _pin(BuildContext context, int index) {
    final pin = _pins[index];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Image(
          'https://picsum.photos/seed/naki-pin-$index/480/${(pin.height * 2).toInt()}',
          alt: pin.title,
          fit: ObjectFit.cover,
          lazyLoad: true,
          radius: BorderRadiusData.all(const Dim.px(8)),
          size: SizeConstraints(
            width: const Dim.percent(100),
            height: Dim.px(pin.height),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            NakiText(
              pin.title,
              style: const TextStyle(
                fontSize: Dim.px(13),
                fontWeight: FontWeight.w500,
                maxLines: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NakiText(
                  pin.author,
                  style: TextStyle(
                    fontSize: const Dim.px(12),
                    color: context.mutedColor,
                  ),
                ),
                Icon(
                  MaterialIcons.icon_round_more_horiz,
                  size: 16,
                  color: context.mutedColor,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Component build(BuildContext context) {
    return ShowcasePage(
      groups: [
        ShowcaseGroup(
          title: 'Layout',
          subtitle: 'Row, Column and friends, as flexbox and grid underneath.',
          demos: [
            Demo(
              name: 'Card',
              child: Container(
                decoration: BoxDecoration(
                  gradient: _aurora,
                  borderRadius: BorderRadiusData.all(const Dim.px(12)),
                  padding: const EdgeInsets.all(Dim.px(16)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Card(
                      padding: EdgeInsets.all(Dim.px(16)),
                      child: NakiText('Card'),
                    ),
                    Card.outlined(
                      padding: EdgeInsets.all(Dim.px(16)),
                      child: NakiText('Card.outline'),
                    ),
                    Card.filled(
                      padding: EdgeInsets.all(Dim.px(16)),
                      child: NakiText('Card.filled'),
                    ),
                    Card.glass(
                      padding: EdgeInsets.all(Dim.px(16)),
                      child: NakiText('Card.glass'),
                    ),
                  ],
                ),
              ),
            ),
            Demo(
              name: 'Stack & Positioned',
              child: Stack(
                width: const Dim.percent(100),
                height: const Dim.px(140),
                children: [
                  Positioned.fill(
                    child: Container(
                      width: const Dim.percent(100),
                      height: const Dim.percent(100),
                      decoration: BoxDecoration(
                        gradient: _aurora,
                        borderRadius: BorderRadiusData.all(const Dim.px(12)),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: Dim.px(12),
                    right: Dim.px(12),
                    child: Card.glass(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dim.px(12),
                        vertical: Dim.px(6),
                      ),
                      child: NakiText('Featured'),
                    ),
                  ),
                ],
              ),
            ),
            Demo(
              name: 'Wrap',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in const [
                    'Jaspr',
                    'Dart',
                    'SSR',
                    'Hydration',
                    'Theming',
                    'Forms',
                    'Overlays',
                  ])
                    Card.filled(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dim.px(12),
                        vertical: Dim.px(6),
                      ),
                      child: NakiText(tag),
                    ),
                ],
              ),
            ),
            Demo(
              name: 'ExpansionTile',
              child: ExpansionTile(
                title: const NakiText('Does it hydrate?'),
                leading: const Icon(MaterialIcons.icon_round_info, size: 18),
                backgroundColor: context.surfaceVariantColor,
                collapsedShape: const BorderData(
                  radius: BorderRadiusData.circular,
                ),
                radius: BorderRadiusData.all(const Dim.px(20)),
                children: const [
                  NakiText('Yes, on top of Jaspr server rendering.'),
                ],
              ),
            ),
            Demo(
              name: 'AspectRatio',
              child: AspectRatio(
                aspectRatio: AspectRatioType.youtubeVideo,
                child: Container(
                  width: const Dim.raw('min(350px, 100%)'),
                  height: const Dim.percent(100),
                  decoration: BoxDecoration(
                    gradient: _aurora,
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                    borderRadius: BorderRadiusData.all(const Dim.px(12)),
                  ),
                  child: const Bold('YouTube video aspect ratio'),
                ),
              ),
            ),
          ],
        ),
        ShowcaseGroup(
          title: 'Scrolling',
          subtitle: 'Scroll views with physics and scrollbar styling.',
          demos: [
            Demo(
              name: 'ListView - Bouncing Scroll Physics',
              child: Container(
                height: const Dim.px(180),
                child: ListView.builder(
                  itemCount: 20,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dim.px(8)),
                    child: Row(
                      spacing: 12,
                      children: [
                        const Icon(MaterialIcons.icon_round_person),
                        NakiText('Contact ${index + 1}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Demo(
              name: 'GridView',
              child: Container(
                height: const Dim.px(180),
                child: GridView.count(
                  3,
                  mainAxisSpacing: const Dim.px(8),
                  crossAxisSpacing: const Dim.px(8),
                  children: [
                    for (var i = 0; i < 9; i++)
                      GridTile(child: _tile(i, height: const Dim.px(80))),
                  ],
                ),
              ),
            ),
            Demo(
              name: 'CarouselView',
              child: Container(
                height: const Dim.px(120),
                child: CarouselView(
                  itemExtent: const Dim.px(200),
                  mainAxisSpacing: const Dim.px(8),
                  itemSnapping: true,
                  flexWeights: const [1, 2, 1, 0.5, 1, 0.8],
                  children: [
                    for (var i = 0; i < 6; i++)
                      _tile(i, height: const Dim.px(120)),
                  ],
                ),
              ),
            ),
            Demo(
              name: 'Table',
              child: Table(
                border: TableBorder.all(
                  color: context.borderColor,
                  width: const Dim.px(1),
                  borderRadius: BorderRadiusData.all(const Dim.px(8)),
                ),
                headerBorderColor: context.borderColor,
                headers: const [Bold('User'), Bold('Role')],
                rows: const [
                  TableRow(children: [NakiText('John'), NakiText('Admin')]),
                  TableRow(children: [NakiText('Sam'), NakiText('Editor')]),
                  TableRow(children: [NakiText('Kai'), NakiText('Viewer')]),
                ],
              ),
            ),
            Demo(
              name: 'StaggeredView',
              child: Container(
                height: const Dim.px(520),
                child: StaggeredView.count(
                  2,
                  mainAxisSpacing: const Dim.px(8),
                  crossAxisSpacing: const Dim.px(8),
                  children: [
                    for (var i = 0; i < _pins.length; i++) _pin(context, i),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
