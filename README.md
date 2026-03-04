# Divine Office — Traditional Roman Breviary

iOS app for the Traditional Roman Breviary (1962 rubrics). All eight canonical hours with full prayer texts, liturgical calendar, and a WidgetKit home screen widget.

## Features

- All 8 canonical hours: Matins, Lauds, Prime, Terce, Sext, None, Vespers, Compline
- Liturgical calendar with feast/feria detection
- Current hour detection based on time of day
- Full office structure: opening versicle, hymn, psalms with antiphons, chapter, responsory, collect
- Seasonal Marian antiphons at Compline
- WidgetKit widget showing current hour and opening prayer
- Dark theme with gold/cream liturgical aesthetic
- Offline-first — no network required

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Data Source

Uses the [divinum-officium-data](https://github.com/nicokimmel/divinum-officium-data) package for prayer texts, psalms, and liturgical calendar data.

## Build

Open `Breviary.xcodeproj` in Xcode and build. No external dependencies.

## Credits

Built by the Ecclesia Dev team.

Ad Maiorem Dei Gloriam.

## License

All rights reserved.
