# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [3.0.0] - 2026-08-11

### Changed

- Raised the swift-design-system pin to 4.0.0.

### Added

- `.spi.yml`, so Swift Package Index builds and hosts the documentation.
- `CONTRIBUTING.md`, stating that verification happens locally and versions are computed.

### Changed

- Raised the swift-design-system pin to 3.0.0. No public API changed.
- Doc comments, README, and DocC catalogs are now English throughout.
- CI no longer builds or tests; a tag only turns into a GitHub Release.

## [2.0.0] - 2026-07-19

### Changed

- Raised the swift-design-system pin from 1.0.23 to 2.0.1. This is the only
  change in the release. No public API was added, removed, or altered — the
  major version tracks the dependency's generation, not a break in this package.

## [1.1.1] - 2026-07-19

### Added

- DocC catalogs for both targets, including a Getting Started guide.
- `README.ja.md`, with the README split into English and Japanese editions.
- Standard CI workflows: tests, DocC deployment to GitHub Pages, release on tag.

### Changed

- Expanded the doc comments on the error type, the recogniser protocol, and the session.

## [1.1.0] - 2026-03-02

### Added

- `InlineTranscriptView`, a transcript preview that occupies space in the layout
  rather than floating above it, for use inside a `ScrollView` or a sheet where
  an overlay would be clipped.

### Changed

- Extracted the shared transcript body into `TranscriptContent`, now used by both
  the inline and the floating presentations.

## [1.0.1] - 2026-03-01

### Fixed

- The floating transcript overlay covered the input field it belonged to. It now
  measures the host view and positions itself clear of it, instead of relying on
  a fixed offset.

## [1.0.0] - 2026-03-01

### Added

- `SpeechRecognizer`, an actor protocol abstracting the recognition engine and
  returning an `AsyncStream` of partial and final results.
- `AppleSpeechRecognizer`, the default implementation over `SFSpeechRecognizer`,
  with staged microphone and speech-recognition permission requests and a
  configurable silence timeout.
- `VoiceInputSession`, `@Observable` `@MainActor` state exposing `partialText`
  alongside `toggle()`, `confirm()`, and `reset()`.
- `VoiceInputButton`, a microphone toggle that routes refused permissions to Settings.
- `FloatingTranscriptOverlay` and the `.voiceInputOverlay()` modifier, adding a
  live transcript preview to any SwiftUI view.

[Unreleased]: https://github.com/no-problem-dev/swift-voice-input/compare/2.0.0...HEAD
[2.0.0]: https://github.com/no-problem-dev/swift-voice-input/compare/1.1.1...2.0.0
[1.1.1]: https://github.com/no-problem-dev/swift-voice-input/compare/v1.1.0...1.1.1
[1.1.0]: https://github.com/no-problem-dev/swift-voice-input/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/no-problem-dev/swift-voice-input/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/no-problem-dev/swift-voice-input/releases/tag/v1.0.0
