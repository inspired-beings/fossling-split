# Fossling Application GitHub Template

A general-purpose GitHub repository template for [Fossling](https://github.com/inspired-beings) applications —
the Inspired Beings collection of free/libre, adless mobile apps.

## Features

- **License**
  - [GNU Affero General Public License](https://www.gnu.org/licenses/why-affero-gpl.html): 
    - Ensures code can be used in commercial projects but any changes must be open-sourced.
- **Community Standards**
  - Includes all the [recommended Community Standards files](https://opensource.guide) for open-source projects.
- **Trademark Policy**
  - A forks-must-rename policy protecting application names and the "Fossling" collection branding,
    since the AGPL covers copyright, not naming.
- **NOTICE**
  - A skeleton declaring what is not under the AGPL: the visual identity (icon, feature graphic and
    the launcher/store artwork derived from them) under CC BY-SA 4.0 with trademark rights withheld,
    plus a section for third-party assets the app bundles.
- **GitHub Actions Workflow**
  - A self-deleting workflow amending the default "Initial commit" message
    with a [Conventional Commit](https://www.conventionalcommits.org) one: `feat: initialize project`.
- **DCO Enforcement**
  - A workflow requiring a `Signed-off-by` line ([Developer Certificate of Origin](https://developercertificate.org))
    on every pull request commit.
- **EditorConfig**
  - An [EditorConfig](https://editorconfig.org) file following most common coding standards.
- **Renovate**
  - A customized [Renovate](https://github.com/renovatebot/renovate) configuration file
    for automated dependency management.
- **Content Skeletons**
  - `README.app.md` and `fastlane/metadata/android/{en-US,fr-FR}/` store-listing skeletons
    following the Fossling content style (hook line, benefit sections, CTA footer).
- **Flutter Baseline**
  - `mise.toml` (pinned Flutter/Java/Android SDK), `l10n.yaml`, `analysis_options.yaml`,
    and a full Flutter `.gitignore` (keystores and generated localizations included).
- **Pillar Gates (CI)**
  - Accessibility, sustainable design, and security enforced by workflows: `tool/check_release_apk.sh`
    (size budget, forbidden merged-manifest permissions, minSdk anchor — run on the built release APK)
    and `tool/check_security_alerts.sh` (open code-scanning/secret-scanning/Dependabot alerts
    block `v*` releases), plus an advanced-setup CodeQL workflow.

## Bootstrapping a new app

The template ships governance, CI, and content skeletons — not a Flutter project. After generating a repo from it:

1. Run `flutter create` with `--org com.fossling`, keeping this repo's files where they conflict.
2. Replace `README.md` with `README.app.md`; fill every `<placeholder>` there and in
   `fastlane/metadata/android/{en-US,fr-FR}/`.
3. Author the app icon and feature graphic (`assets/icon.svg`, `assets/feature-graphic.svg`) on the shared
   collection background, plus the adaptive/themed Android launcher icons.
4. Fill `NOTICE`: name, year, and one stanza per bundled third-party asset (author, license, source,
   modifications) — or delete that section. Keep the visual-identity section verbatim.
5. Baseline `MAX_MIB` in `tool/check_release_apk.sh` from the first release build (+ ~15% headroom) and
   adjust the forbidden-permission list to the app's privacy posture.
6. Port the accessibility test suite pattern (`test/a11y/` screen-state × locale registry) from a shipped
   Fossling app — [fossling-magnifier](https://github.com/inspired-beings/fossling-magnifier) is the
   reference implementation.
7. Set the release-signing repository secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`) — the `v*` release workflow builds unsigned without them —
   and `SECURITY_ALERTS_TOKEN` for full security-gate coverage.
