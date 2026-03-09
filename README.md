# Leithmail

An open source, server-agnostic JMAP email client for Android, iOS and web.

Works with any JMAP-compliant server and any OIDC-compatible identity provider.
No proprietary backend required.

## Status

Early development. Not yet usable.

## Goals

- Any JMAP server — tested against Stalwart, Apache James, Cyrus IMAP
- Any OIDC identity provider — autodiscovery from email domain
- No vendor dependencies — no Firebase, no proprietary services
- Cross-platform — Android, iOS, web (desktop planned)
- Multiple accounts
- Shared mailboxes and delegated access (JMAP ACL)

## Based on

Forked from [tmail-flutter](https://github.com/linagora/tmail-flutter) by Linagora.  
Original code copyright Linagora, licensed under AGPL-3.0.

## License

AGPL-3.0 — see [LICENSE](LICENSE)