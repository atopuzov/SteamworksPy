# Project Information for Gemini

This document contains important information to streamline our interactions with the SteamworksPy project.

## Development Environment

This project uses a [Nix flake](flake.nix) to provide a consistent development environment. To activate the environment, run:

```shell
nix develop
```

This will provide all the necessary dependencies, including `g++`, `python`, and the Steamworks SDK.

## Steamworks API Headers

The Steamworks API headers are provided by the `steamworks-sdk` derivation within the Nix flake. When inside the `nix develop` shell, the headers can be found in the `steamworks-sdk` package's include directory. You can find the exact path by running `echo $NIX_BUILD_TOP` inside the nix shell and looking for the `steamworks-sdk` directory.

## Building and Cleaning

The project is built using `make`. The following commands are available:

*   **Build:** `make` or `make makeall`
*   **Clean:** `make clean`

## Upstream Reference

The upstream version of `SteamworksPy.cpp` is available at:
<https://raw.githubusercontent.com/philippj/SteamworksPy/refs/heads/master/library/SteamworksPy.cpp>

This can be used as a reference to see if they have necessary code we need, but make sure to adapt to our current repository's code style.

## SteamAPI Documentation

The official SteamAPI documentation can be found at:
<https://partner.steamgames.com/doc/api>

## ISteamInput Implementation Status

This section summarizes the implementation status of the `ISteamInput` interface.

### Implemented Functions:

*   `ActivateActionSet`
*   `ActivateActionSetLayer`
*   `DeactivateActionSetLayer`
*   `DeactivateAllActionSetLayers`
*   `GetActiveActionSetLayers`
*   `GetAnalogActionData`
*   `GetAnalogActionHandle`
*   `GetAnalogActionOrigins`
*   `GetConnectedControllers`
*   `GetControllerForGamepadIndex`
*   `GetCurrentActionSet`
*   `GetDigitalActionData`
*   `GetDigitalActionHandle`
*   `GetDigitalActionOrigins`
*   `GetGamepadIndexForController`
*   `GetGlyphPNGForActionOrigin` (corrected from `GetGlyphForActionOrigin`)
*   `GetInputTypeForHandle`
*   `GetMotionData`
*   `GetStringForActionOrigin`
*   `RunFrame`
*   `SetLEDColor`
*   `Shutdown`
*   `SetInputActionManifestFilePath`
*   `StopAnalogActionMomentum`
*   `TriggerVibration`
*   `TriggerVibrationExtended`
*   `GetActionOriginFromXboxOrigin`
*   `TranslateActionOrigin`
*   `GetDeviceBindingRevision`
*   `GetRemotePlaySessionID`
*   `Legacy_TriggerHapticPulse`
*   `Legacy_TriggerRepeatedHapticPulse`

### Functions Available in `isteaminput.h` but Not Implemented:

*   `BWaitForData`
*   `BNewDataAvailable`
*   `EnableDeviceCallbacks`
*   `EnableActionEventCallbacks`
*   `GetStringForDigitalActionName`
*   `GetGlyphSVGForActionOrigin`
*   `GetGlyphForActionOrigin_Legacy`
*   `GetStringForAnalogActionName`
*   `TriggerSimpleHapticEvent`
*   `GetStringForXboxOrigin`
*   `GetGlyphForXboxOrigin`
*   `GetSessionInputConfigurationSettings`
*   `SetDualSenseTriggerEffect`
*   `ShowAnalogActionOrigins`
*   `ShowDigitalActionOrigins`

**Note:** Only `SteamworksPy.cpp` is modified for new implementations; `steamworks.py` is not directly edited.
*   `BWaitForData`
*   `BNewDataAvailable`
*   `EnableDeviceCallbacks`
*   `EnableActionEventCallbacks`
*   `GetStringForDigitalActionName`
*   `GetGlyphSVGForActionOrigin`
*   `GetGlyphForActionOrigin_Legacy`
*   `GetStringForAnalogActionName`
*   `TriggerSimpleHapticEvent`
*   `GetStringForXboxOrigin`
*   `GetGlyphForXboxOrigin`
*   `GetSessionInputConfigurationSettings`
*   `SetDualSenseTriggerEffect`
*   `ShowAnalogActionOrigins`
*   `ShowDigitalActionOrigins`

## Continuous Integration and Release Workflow

This project utilizes GitHub Actions for continuous integration, building, and releasing artifacts for Linux, macOS (x86_64 and arm64 fat binary), and Windows.

### Workflow Details

*   **Workflow File:** `.github/workflows/build.yml`
*   **Trigger:** The workflow is triggered on every `push` event to the `build` branch.

### Build Process

1.  **Steamworks SDK Handling:**
    *   The Steamworks SDK is downloaded from the URL specified in `steamworks_sdk_url.txt`.
    *   The downloaded SDK is cached across workflow runs using `actions/cache@v3` to speed up subsequent builds.
    *   Platform-specific commands are used to read the URL and extract the SDK (bash for Linux/macOS, PowerShell for Windows).

2.  **Makefile Enhancements:**
    *   The `Makefile` (`Makefile`) has been refactored for improved flexibility and robustness.
    *   It defines `STEAM_INCLUDE_DIR` and `STEAM_LIB_DIR` variables, which can be overridden by the GitHub Actions workflow. This allows for local builds to use a consistent configuration.
    *   **macOS Specifics:**
        *   The `Makefile` handles the creation of a universal ("fat") binary for macOS, combining `x86_64` and `arm64` architectures.
        *   `MACOSX_DEPLOYMENT_TARGET=10.12` is set within the `Makefile` for macOS builds to ensure backward compatibility.

3.  **Platform-Specific Builds:**
    *   **Linux:** Builds `SteamworksPy.so`.
    *   **macOS:** Builds `SteamworksPy.dylib` (fat binary for x86_64 and arm64).
    *   **Windows:** Builds `SteamworksPy.dll` using MSVC and `steam_api64.lib`.

### Release Strategy

*   **Single "latest" Release:** The workflow maintains a single GitHub Release named "Latest Build" with the tag `latest`.
*   **Overwrite on Push:** On each successful workflow run on the `build` branch, the existing `latest` release and its corresponding tag are deleted, and a new one is created.
*   **Artifacts:** The compiled `SteamworksPy.so`, `SteamworksPy.dylib`, and `SteamworksPy.dll` files are uploaded as assets to this `latest` release.

### How to Trigger and Use

1.  **Push to `build` branch:** All changes pushed to the `build` branch will automatically trigger the CI/CD pipeline.
2.  **Monitor Workflow:** Go to the "Actions" tab in the GitHub repository to monitor the progress of the workflow.
3.  **Download Release:** Once the workflow completes successfully, the latest build artifacts can be downloaded from the "Latest Build" release on the repository's Releases page.