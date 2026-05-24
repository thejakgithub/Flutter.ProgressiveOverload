# AGENTS.md

This file defines how coding agents should work in this repository.

## Project Goal

Build and maintain a Flutter application using **Clean Architecture** with strong separation of concerns, testability, and predictable state.

## Core Principles

1. Keep layers independent: `presentation -> domain -> data`.
2. Domain layer must not depend on Flutter or external frameworks.
3. Prefer small, focused use cases over large service classes.
4. Use immutable models and explicit error handling (`Result`, `Either`, or custom Failure types).
5. Write tests for domain and data behavior before complex refactors.

## Recommended Tech Stack

- Flutter (stable)
- State management: Riverpod (preferred)
- Routing: go_router
- Data models: manual immutable classes + explicit `fromMap` / `toMap`
- Backend database: Supabase (Postgres)
- Backend services: Supabase Auth + Storage (when needed)
- HTTP: dio
- Local storage: shared_preferences / hive / drift (choose per feature)

If the codebase already uses a different stack, keep consistency with existing patterns.

## Folder Structure (Feature-First + Layered)

Use this structure for each feature:

```
lib/
  core/
    error/
    network/
    usecase/
    utils/
    constants/
  features/
    <feature_name>/
      presentation/
        pages/
        widgets/
        providers/
      domain/
        entities/
        repositories/
        usecases/
      data/
        models/
        datasources/
        repositories/
```

## Layer Rules

### Presentation

- Contains UI, view models/providers, and UI state.
- No direct HTTP/database calls.
- Calls domain use cases only.
- Keep widgets dumb when possible; move logic to providers/controllers.

**UI Best Practices:**

- **Keyboard Management:** Always add `GestureDetector` with `behavior: HitTestBehavior.translucent` and `onTap: () => FocusScope.of(context).unfocus()` to wrap the entire `Scaffold` (not just the body) for dismissing keyboard when tapping anywhere including AppBar. Structure: `return GestureDetector(child: Scaffold(...))`.
- **Modal Focus Handling:** Before opening modals/bottom sheets, call `FocusManager.instance.primaryFocus?.unfocus();` and call it again after the modal closes (`await showModalBottomSheet(...)`) to prevent text fields from auto-refocusing.
- **Widget Extraction:** Extract reusable widgets into separate widget classes (private `_WidgetName` for page-specific, public for shared).
- **Theming:** Use centralized theme colors from `AppColors` class (located in `core/theme/app_colors.dart`). Never hardcode color values.
- **Component Reusability:** Create shared components in `core/widgets/` for common UI patterns (buttons, cards, inputs, etc.).

### Domain

- Contains entities, repository contracts, and use cases.
- No Flutter imports.
- No JSON parsing logic.
- Business rules live here.

### Data

- Implements domain repository contracts.
- Contains DTO/models, mappers, and remote/local data sources.
- Handles serialization, caching, retry, and network exceptions.
- Maps external errors to domain `Failure` types.

## Dependency Direction

Allowed:

- `presentation` depends on `domain`
- `data` depends on `domain`
- `domain` depends on nothing from `presentation` or `data`

Not allowed:

- `domain -> data`
- `domain -> presentation`
- `presentation -> data` (except via domain abstractions)

## Naming Conventions

- Entity: `Workout`, `UserProfile`
- Model/DTO: `WorkoutModel`
- Repository contract: `WorkoutRepository`
- Repository implementation: `WorkoutRepositoryImpl`
- Use case: `GetWorkoutsUseCase`
- Params class: `GetWorkoutsParams`
- Failure types: `NetworkFailure`, `CacheFailure`, `ValidationFailure`

## Mapping Rules

- Never expose data models to presentation.
- Convert DTO/model -> entity in data layer.
- Keep mapper functions explicit and testable.
- Prefer manual serializers (`fromMap`, `toMap`, `fromJson`, `toJson`) over generated code.

## State Management Rules (Riverpod)

- One provider/controller per screen concern.
- Keep state immutable.
- Represent async state with `AsyncValue` or a sealed UI state.
- Side effects should go through use cases, not directly from widgets.

## Error Handling

- Catch low-level exceptions in data sources.
- Convert to domain failures in repositories.
- Return typed failures from use cases.
- Presentation maps failures to user-friendly messages.

## Testing Strategy

Minimum expectation per feature:

1. Domain use case tests
2. Repository implementation tests (with mocked data sources)
3. Mapper/model serialization tests
4. Widget/provider tests for critical presentation flows

When adding logic:

- Add or update tests in the same change.
- Do not merge architectural refactors without regression tests.

## Model Serialization

- Do not use `freezed` or `json_serializable`.
- Implement immutable models manually with clear constructors.
- Keep `fromJson`/`toJson` logic inside data models only.
- Add tests for serialization/deserialization edge cases.

## AI-Generated Model Quality Gate

AI can generate model boilerplate, but every generated model must pass this gate before merge.

Required checks:

1. Immutability: all fields are `final`, no mutable collections exposed directly.
2. Correct nullability: optional vs required fields match API contract and domain rules.
3. Deterministic serialization: `fromJson` and `toJson` preserve values and key names exactly.
4. Safe parsing: numeric/date/bool conversion handles inconsistent API payloads defensively.
5. No domain leakage: DTO/model stays in data layer and is mapped to domain entities.
6. Equality semantics: implement predictable equality/hash behavior for stable tests and state updates.
7. Copy/update path: provide a clear update strategy (`copyWith` or equivalent constructor pattern).
8. Backward compatibility: new fields must not break existing payload parsing.

Required tests for generated/updated models:

1. `fromJson` happy path test.
2. `fromJson` missing/nullable field test.
3. `toJson` snapshot/expected map test.
4. Round-trip test: `fromJson -> toJson` consistency.
5. Mapper test: model to entity conversion including edge values.

PR checklist for model changes:

- Include sample payload used for generation or adaptation.
- Explain any manual edits after AI output.
- Confirm all model and mapper tests pass.
- Confirm no presentation/domain layer imports data model types.

## Agent Working Rules

1. Before implementing, identify target layer (`presentation`, `domain`, or `data`).
2. If a change crosses layers, start at domain contracts/use cases first.
3. Do not bypass repository contracts.
4. Keep each commit scoped to a single feature or architectural concern.
5. Prefer incremental PRs: domain -> data -> presentation.
6. If existing code conflicts with this guide, follow existing project conventions and document deviations in PR notes.

## Definition of Done

A task is done when:

- Architecture boundaries are respected.
- New logic has tests.
- Lints pass.
- Serialization and mapper tests pass (if models changed).
- No dead code or unused providers remain.

## Suggested Commands

```bash
flutter pub get
flutter analyze
flutter test
```

Optional formatting:

```bash
dart format .
```
