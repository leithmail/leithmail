# Leithmail

An open source, server-agnostic JMAP email client for web, Android, iOS.

Works with any JMAP-compliant server and any OIDC-compatible identity provider.
No proprietary backend required.

## Status

Early development. Not yet usable.

## Goals

- Pure client-side
- Any JMAP server — tested against Stalwart, Apache James, Cyrus IMAP
- Any OIDC identity provider — autodiscovery from email domain
- No vendor locks — no Linagora, no Firebase, no proprietary services
- Cross-platform — web, Android, iOS (desktop planned)
- Multiple accounts
- Shared mailboxes and delegated access (JMAP ACL)

## Based on

Parts of repository are based on [tmail-flutter](https://github.com/linagora/tmail-flutter) by Linagora.

## License

AGPL-3.0 — see [LICENSE](LICENSE)