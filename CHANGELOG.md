# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Boon Selector now reloads the page when you select a rarity
- Boon Selector now correctly displays Daedalus hammer upgrades and supports selecting the Icarus upgraded versions
- Boon Selector rarity buttons no longer switch to english after being clicked on supported non-english locales
- Boon Manager now reloads the page altering the rarity or level of any boon
- Boon Manager now correctly displays level scaled boon values
- Boon Manager rarity mode can no longer upgrade Arachne dresses (it had no effect)
- Boon Manager rarity mode can now upgrade and downgrade compatible Daedalus hammer upgrades
- Various logic improvements
- Updated all missing translations on non-english locales

## [0.10.14] - 2025-06-26

### Changed

- Fixed downgrading rarity in boon manager

## [0.10.13] - 2025-06-25

### Changed

- Reworked handling of Hexes
- Fixed various crashes related to Hexes
- Picking an Hex while having a Hex already will remove the equipped Hex and attached Path of Stars upgrades before equipping the new Hex
- Deleting a Hex in the Boon Manager will also delete all its attached Path of Stars upgrades

## [0.10.12] - 2025-06-23

### Changed

- Fixed Boss Selector crashing
- Fixed inventory tab background disappearing

## [0.10.11] - 2025-06-22

### Changed

- Fixed manifest

## [0.10.10] - 2025-06-22

### Changed

- Fixed not being able to plant multiple seeds at once with the mod installed
- Imported removed assets from this update (god icons and menu background)

## [0.10.9] - 2025-06-18

### Changed

- Fixed for new update

## [0.10.8] - 2025-02-20

### Changed

- Fixed for new update
- Added Ares

## [0.10.7] - 2024-10-18

### Changed

- You can now remove resources with the Resource Menu

## [0.10.6] - 2024-10-17

### Fixed

- Fixed hammers

## [0.10.5] - 2024-10-17

### Changed

- Added Athena
- Added Dionysus
- Added Prometheus to Boss Selector
- Starting a boss fight with Boss Selector no longer saves your game

## [0.10.4] - 2024-07-21

### Changed

- Added Practical Gods integration by zannc

## [0.10.3] - 2024-06-19

### Fixed

- Fixed for modutil 4.0

### Added

- Added pt-br translation by Seceip

## [0.10.2] - 2024-05-29

### Fixed

- Fixed saved states not working

## [0.10.1] - 2024-05-29

### Fixed

- Fixed boss selector crash

## [0.10.0] - 2024-05-28

### Changed

- Ported to Hell2Modding format

### Fixed

- Fixed various issues with LoadState

## [0.9.0] - 2024-05-20

### Fixed

- Fixed all mode rarity affecting keepsakes and altar cards

### Added

- Save State
- Load State
- Boss Selector
- Consumable Selector (WIP)
- Kill Player

## [0.8.0] - 2024-05-18

### Added

- Medea
- Icarus
- Circe

## [0.7.5] - 2024-05-16

### Changed

- Removed WIP button

## [0.7.4] - 2024-05-15

### Fixed

- Thunderstore fixes

## [0.7.3] - 2024-05-15

### Fixed

- Thunderstore fixes

## [0.7.2] - 2024-05-15

### Fixed

- Fix infusion color in boon selector and manager
- Fix being unable to upgrade rarity of certain boons like hermes and chaos

### Added

- First version of the mod!

[unreleased]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.14...HEAD
[0.10.14]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.13...0.10.14
[0.10.13]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.12...0.10.13
[0.10.12]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.11...0.10.12
[0.10.11]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.10...0.10.11
[0.10.10]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.9...0.10.10
[0.10.9]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.8...0.10.9
[0.10.8]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.7...0.10.8
[0.10.7]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.6...0.10.7
[0.10.6]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.5...0.10.6
[0.10.5]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.4...0.10.5
[0.10.4]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.3...0.10.4
[0.10.3]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.2...0.10.3
[0.10.2]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.1...0.10.2
[0.10.1]: https://github.com/PonyWarrior/PonyMenu/compare/0.10.0...0.10.1
[0.10.0]: https://github.com/PonyWarrior/PonyMenu/compare/0.9.0...0.10.0
[0.9.0]: https://github.com/PonyWarrior/PonyMenu/compare/0.8.0...0.9.0
[0.8.0]: https://github.com/PonyWarrior/PonyMenu/compare/0.7.5...0.8.0
[0.7.5]: https://github.com/PonyWarrior/PonyMenu/compare/0.7.4...0.7.5
[0.7.4]: https://github.com/PonyWarrior/PonyMenu/compare/0.7.3...0.7.4
[0.7.3]: https://github.com/PonyWarrior/PonyMenu/compare/0.7.2...0.7.3
[0.7.2]: https://github.com/PonyWarrior/PonyMenu/compare/013ff8c60de07956d7d0b7629076b09d4cad44dc...0.7.2
