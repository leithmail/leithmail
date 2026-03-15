#!/usr/bin/env bash
set -e

modules=("core" "model" "contact" "forward" "rule_filter" "fcm" "email_recovery" "server_settings" "scribe" "labels")

# @cmd Run code generation and extract ARB translation templates.
codegen() {
    for mod in "${modules[@]}"; do
    (
        cd "$mod"
        flutter pub get
        dart run build_runner build --delete-conflicting-outputs
    )
    done

    # For the parent module
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs &&

    # Localozations
    dart run intl_generator:extract_to_arb --suppress-last-modified --output-dir=./lib/l10n lib/main/localizations/app_localizations.dart &&
        dart run intl_generator:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/main/localizations/app_localizations.dart lib/l10n/intl*.arb

    # For scribe module localizations
    (
    cd scribe
    dart run intl_generator:extract_to_arb --suppress-last-modified --output-dir=./lib/scribe/ai/l10n lib/scribe/ai/localizations/scribe_localizations.dart &&
        dart run intl_generator:generate_from_arb --output-dir=lib/scribe/ai/l10n --no-use-deferred-loading lib/scribe/ai/localizations/scribe_localizations.dart lib/scribe/ai/l10n/intl*.arb
    )

}

eval "$(argc --argc-eval "$0" "$@")"