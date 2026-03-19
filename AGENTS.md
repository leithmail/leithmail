# Leithmail — Project Instructions

## Project Overview

**Leithmail** is an open-source, server-agnostic JMAP email client for web (MVP), Android, and iOS.
Repo: https://github.com/leithmail/leithmail

- Pure client-side Flutter app — no proprietary backend
- Works with any JMAP-compliant server (Stalwart, Apache James, Cyrus IMAP)
- Works with any OIDC-compatible identity provider via autodiscovery from email domain
- No vendor lock-in (no Linagora, no Firebase, no proprietary services)
- Supports multiple accounts, shared mailboxes, delegated access (JMAP ACL)

**Runtime:** Flutter 3.41.4 (stable), Dart 3.11.1, target: web (MVP), then Android/iOS.

---

## Architecture

### Pattern: Clean Architecture

```
lib/
  core/           # Shared abstractions, interfaces, utilities
  data/           # Implementations of repositories and services
  domain/         # Entities, repository interfaces, use cases
  presentation/   # Screens, controllers, widgets
  main.dart
  app.dart
```

### Layers

- **Domain**: Pure Dart. Entities (immutable, with `json_serializable`), repository interfaces, use case classes. No Flutter imports, no framework dependencies.
- **Data**: Implements domain repository interfaces. Contains JMAP client wrapper, OIDC client, local/secure storage. All external dependencies live here.
- **Presentation**: Flutter widgets and controllers. No business logic — controllers orchestrate use cases and expose state via Signals.
- **Core**: Cross-cutting concerns — failure types, abstract service interfaces, utilities.

### Dependency Direction

```
presentation → domain ← data
                core ← all layers
```

---

## State Management & Reactivity

**No GetX.** GetX is being removed. Do not introduce or use any GetX APIs (`GetxController`, `Obx`, `.obs`, `Get.find`, `GetBuilder`, bindings, etc.).

### Signals.dart

Use [`signals`](https://pub.dev/packages/signals) for all reactive state.

**Controllers** expose public `Signal<T>` and `Computed<T>` fields.  
**Views** observe them using `Watch` or `watch(context)`.

```dart
// Controller
class MailboxController {
  final Signal<List<Mailbox>> mailboxes = signal([]);
  final Signal<bool> isLoading = signal(false);
  late final Computed<bool> isEmpty = computed(() => mailboxes().isEmpty);

  MailboxController(this._fetchMailboxesUseCase);

  Future<void> load() async {
    isLoading.value = true;
    final result = await _fetchMailboxesUseCase.execute();
    result.fold(
      (failure) { /* handle */ },
      (list) => mailboxes.value = list,
    );
    isLoading.value = false;
  }
}

// View
Watch((context) => isLoading.value
  ? CircularProgressIndicator()
  : MailboxList(mailboxes: mailboxes.value),
)
```

---

## Dependency Injection

**No DI library.** Use constructor injection throughout.

Controllers receive their dependencies (use cases, repositories, services) via constructor parameters. Wire them up manually in the widget tree or a top-level composition root.

```dart
// Composition root (e.g. in main.dart or app.dart)
final storageService = StorageServiceImplLocal();
final accountRepo = AccountRepositoryImpl(storageService);
final loginController = LoginController(LoginUseCase(accountRepo));
```

Pass controllers down via `InheritedWidget`, `InheritedNotifier`, or constructor — whichever is simplest for the screen. Do not use service locators or global singletons.

---

## Routing

**Undecided between `go_router` and manual `Navigator`.** Do not finalize or add a router dependency without being asked. The app has very few pages (dashboard, email viewer, compose, account settings, add account/login) and must behave as a **SPA on web** — browser history integration is explicitly unwanted.

For now, use Flutter's built-in `Navigator.push/pop` or `IndexedStack` for shell navigation. Raise the routing question before implementing any deep-link or URL-based navigation.

---

## JMAP Integration

Use [`jmap_dart_client`](https://pub.dev/packages/jmap_dart_client) as the underlying JMAP library, but **always behind an abstract interface**.

```dart
// domain/services/jmap_service.dart
abstract class JmapService {
  Future<Session> getSession(Uri serverUrl, Credentials credentials);
  Future<List<Mailbox>> getMailboxes(Session session);
  Future<EmailPage> getEmails(Session session, MailboxId mailboxId, {int limit, String? afterId});
  Future<Email> getEmailDetails(Session session, EmailId id);
  Future<void> sendEmail(Session session, EmailDraft draft);
  // etc.
}

// data/jmap_service_impl.dart
class JmapServiceImpl implements JmapService {
  // wraps jmap_dart_client
}
```

This allows swapping or mocking the JMAP layer entirely in tests or future refactors.

---

## OIDC / Authentication

Use a standard Flutter OIDC package (TBD — `flutter_appauth` or `openid_client`). Do **not** reuse tmail-flutter's OIDC implementation as it is tied to Linagora infrastructure.

OIDC provider is discovered automatically from the user's email domain (RFC 5785 / `.well-known/openid-configuration`).

Authentication flow:
1. User enters email address
2. App resolves JMAP `/.well-known/jmap` and OIDC discovery from domain
3. OIDC login (redirect/popup on web)
4. Token stored securely, session established

---

## Reuse from tmail-flutter

The following parts of [tmail-flutter](https://github.com/linagora/tmail-flutter) may be ported/adapted:

| What                        | Notes                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------- |
| **UI widgets / components** | Port as needed, strip GetX/Linagora dependencies, adapt to Signals                        |
| **Rich text email editor**  | Port the editor widget, decouple from GetX state                                          |
| **JMAP API layer**          | Use as reference only — rewrite behind `JmapService` abstraction using `jmap_dart_client` |

Do **not** port: Linagora auth, Firebase integrations, proprietary backend calls, GetX bindings, or any `com.linagora` package dependencies.

---

## UI Style

- Material Design 3, close to Gmail / tmail aesthetic
- Flutter `MaterialApp` with Material 3 theme
- Responsive layout (web-first for MVP — sidebar + content pane)
- No custom design system needed for MVP; use Material components directly

---

## Code Conventions

### File & Folder Naming
- `snake_case` for all file names
- Feature folders under `presentation/`: `presentation/dashboard/`, `presentation/login/`, `presentation/compose/`, etc.
- Each feature folder contains: `[feature]_screen.dart`, `[feature]_controller.dart`
- No `_bindings.dart` files (those were GetX — remove them)

### Controller Pattern
```dart
class FeatureController {
  // 1. Public signals (state)
  final Signal<X> someState = signal(initialValue);

  // 2. Private dependencies
  final SomeUseCase _useCase;

  // 3. Constructor injection
  FeatureController(this._useCase);

  // 4. Public methods (actions)
  Future<void> doSomething() async { ... }

  // 5. Dispose signals if needed
  void dispose() { someState.dispose(); }
}
```

### Use Cases
One public method, `execute(...)`. Return `Either<Failure, T>` using `fpdart` or a simple `Result` type.

```dart
class FetchMailboxesUseCase {
  final MailboxRepository _repository;
  FetchMailboxesUseCase(this._repository);

  Future<Either<Failure, List<Mailbox>>> execute(Session session) =>
      _repository.getMailboxes(session);
}
```

### Entities
- Immutable (`final` fields, `const` constructors where possible)
- `json_serializable` for serialization (keep `.g.dart` files)
- `copyWith` methods for updates
- Value equality (`Equatable` or manual `==`/`hashCode`)

### Error Handling
- Use `Either<Failure, T>` throughout domain and data layers
- Define specific `Failure` subclasses in `core/error/failure.dart`
- Never throw exceptions across layer boundaries — convert to `Failure`

### Imports
- Prefer relative imports within the same feature
- Use absolute `package:leithmail/...` imports across features/layers

---

## Testing

Tests are written **only when explicitly requested**. Existing tests in `test/` follow the contract-testing pattern for storage services — maintain that style when adding new tests.

---

## MVP Scope (Web)

In priority order:

1. **OIDC login + account setup** — email entry → autodiscovery → OIDC redirect → session stored
2. **Dashboard shell** — responsive sidebar (mailbox list) + email list pane + reading pane
3. **Mailbox list** — fetch and display mailboxes from JMAP session
4. **Email list** — paginated email list for selected mailbox
5. **Email viewer** — read email, render HTML body safely (sandboxed iframe or `flutter_widget_from_html`)
6. **Compose / send** — rich text editor (ported from tmail), send via JMAP
7. **Account management & settings** — add/remove accounts, switch active account, basic preferences

Desktop (Windows/Linux/macOS) is planned but not in scope for MVP.

---

## Key Dependencies (current / planned)

| Package                              | Purpose                                    |
| ------------------------------------ | ------------------------------------------ |
| `signals`                            | Reactive state — replaces GetX observables |
| `jmap_dart_client`                   | JMAP protocol implementation               |
| `flutter_appauth` or `openid_client` | OIDC authentication                        |
| `fpdart`                             | Functional types (`Either`, `Option`)      |
| `json_serializable` / `build_runner` | Entity serialization                       |
| `flutter_secure_storage`             | Secure credential storage                  |
| `shared_preferences`                 | Non-sensitive local storage                |
| `equatable`                          | Value equality for entities                |

---

## What to Avoid

- **No GetX** anywhere — not for routing, state, DI, or anything else
- **No Linagora/tmail proprietary dependencies**
- **No Firebase**
- **No global singletons or service locators**
- **No business logic in widgets** — keep screens as thin views
- **No browser history / deep-link routing** until explicitly decided