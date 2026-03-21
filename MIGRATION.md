# Reciplan Architecture Migration

## Summary

Reciplan was migrated from a `provider + ChangeNotifier + GetIt` setup to a `flutter_bloc` architecture based on `Cubit`.

The goals of the migration were:

- remove shared mutable view-model state tied loosely to screen lifecycle
- centralize database access behind repositories
- make feature state explicit with immutable bloc state objects
- separate business logic from UI more clearly
- simplify folder structure so logic and presentation are easier to navigate

## What Changed

### State management

Old approach:

- `ChangeNotifier` view models
- `GetIt` service locator for view model access
- widget-managed listeners and subscriptions
- theme state managed outside bloc

New approach:

- `flutter_bloc` with `Cubit`
- root `RepositoryProvider` for repositories and services
- feature-scoped `BlocProvider` for screen state
- app-wide cubits only for app-wide state like theme/settings
- explicit immutable state classes per feature

### Database flow

Old approach:

- widgets and shared view models were closer to DAO streams
- subscription ownership was spread across screens/view models
- plan data and recipe data were exposed in DB-shaped structures

New approach:

- `Floor` remains the local database engine
- DAOs are responsible for SQL only
- repositories are the only layer that talks to DAOs
- cubits call repositories
- widgets render bloc state only

Current flow:

`UI -> Cubit -> Repository -> DAO -> Floor/SQLite`

## Folder Structure

The codebase is now organized around two main concerns:

- [lib/logic](/Users/eghan/StudioProjects/reciplan3/lib/logic): business logic and data flow
- [lib/presentation](/Users/eghan/StudioProjects/reciplan3/lib/presentation): screens and reusable UI

### Logic

[lib/logic](/Users/eghan/StudioProjects/reciplan3/lib/logic) contains:

- [app](/Users/eghan/StudioProjects/reciplan3/lib/logic/app): app bootstrap, root wiring, theme/settings cubits
- [core](/Users/eghan/StudioProjects/reciplan3/lib/logic/core): shared app models and enums
- [data](/Users/eghan/StudioProjects/reciplan3/lib/logic/data): entities, DAOs, DB setup, repositories, local services
- [recipes](/Users/eghan/StudioProjects/reciplan3/lib/logic/recipes): recipe-related cubits and states
- [plan](/Users/eghan/StudioProjects/reciplan3/lib/logic/plan): meal-plan cubits and states
- [settings](/Users/eghan/StudioProjects/reciplan3/lib/logic/settings): import/export cubit and state

### Presentation

[lib/presentation](/Users/eghan/StudioProjects/reciplan3/lib/presentation) contains:

- [features/add](/Users/eghan/StudioProjects/reciplan3/lib/presentation/features/add)
- [features/plan](/Users/eghan/StudioProjects/reciplan3/lib/presentation/features/plan)
- [features/recipes](/Users/eghan/StudioProjects/reciplan3/lib/presentation/features/recipes)
- [features/settings](/Users/eghan/StudioProjects/reciplan3/lib/presentation/features/settings)
- [features/shell](/Users/eghan/StudioProjects/reciplan3/lib/presentation/features/shell)
- [widgets](/Users/eghan/StudioProjects/reciplan3/lib/presentation/widgets): shared reusable UI widgets

Each feature now owns its screens directly. The extra nested `presentation/` folders were removed.

## Main Architectural Decisions

### 1. `Cubit` over event-based `Bloc`

The app mostly needs straightforward local-state orchestration rather than complex event pipelines. `Cubit` keeps the implementation smaller and easier to follow.

### 2. Repository-first local DB access

Repositories now define the public data contract for the app. This reduces coupling to `Floor` entities and makes it easier to evolve queries without forcing UI changes.

### 3. Typed models instead of raw maps/ids

The migration introduced shared models and enums such as:

- `MealType`
- `MealSlot`
- `RecipeDraft`
- `PlannedMeal`
- `DayPlan`
- `WeekPlan`

This replaced more fragile patterns like raw integer meal values and UI-facing map structures.

### 4. Root wiring through providers, not service locator

`GetIt` was removed. The app now creates dependencies during bootstrap and provides them through the widget tree.

## Key Files

Important entry points after the migration:

- [main.dart](/Users/eghan/StudioProjects/reciplan3/lib/main.dart)
- [app.dart](/Users/eghan/StudioProjects/reciplan3/lib/logic/app/app.dart)
- [app_dependencies.dart](/Users/eghan/StudioProjects/reciplan3/lib/logic/app/bootstrap/app_dependencies.dart)
- [recipe_repository.dart](/Users/eghan/StudioProjects/reciplan3/lib/logic/data/repositories/recipe_repository.dart)
- [meal_plan_repository.dart](/Users/eghan/StudioProjects/reciplan3/lib/logic/data/repositories/meal_plan_repository.dart)

## Removed Patterns

The migration removed these app-level patterns:

- `GetIt`
- `provider`
- `ChangeNotifier` feature view models
- manual screen-owned data listeners for feature state
- old `locator` usage

## Verification

After the migration and folder cleanup:

- `flutter analyze` passes
- `flutter test` passes

## Follow-Up Work

The migration is complete, but a few follow-ups would improve maintainability further:

- expand bloc and repository test coverage
- decide whether [lib/util](/Users/eghan/StudioProjects/reciplan3/lib/util) should move into `logic/core` or be split into logic vs presentation helpers
- reduce global shared widgets by pushing feature-specific widgets into each feature folder where appropriate
- refresh [README.md](/Users/eghan/StudioProjects/reciplan3/README.md) so it reflects the new architecture
