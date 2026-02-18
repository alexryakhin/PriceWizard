fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Mac

### mac metadata_download

```sh
[bundle exec] fastlane mac metadata_download
```

Download current metadata from App Store Connect into fastlane/metadata

### mac metadata_upload

```sh
[bundle exec] fastlane mac metadata_upload
```

Upload local metadata from fastlane/metadata to App Store Connect

### mac metadata_check

```sh
[bundle exec] fastlane mac metadata_check
```

Validate app metadata (precheck against App Store Connect)

### mac metadata_init

```sh
[bundle exec] fastlane mac metadata_init
```

Initialize metadata folder (downloads existing or creates structure)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
