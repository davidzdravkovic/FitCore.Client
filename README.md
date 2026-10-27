# FitCore.Client

Flutter client for [FitCore](https://github.com/davidzdravkovic/FitCore) — the multi-tenant gym CRM. Four portals in one app: platform, gym owner, staff, and member.

**Landing page → [https://fitcore-landing.astibosoft.com](https://fitcore-landing.astibosoft.com)**  
Access to the app is invite-only. Domain rules and deploy live in the [API repo](https://github.com/davidzdravkovic/FitCore).

---

## What this repo is for

The API owns the rules. This repo is the product surface those rules are used through: who signs in, what they see, and how visits are booked on the calendar.

The strongest part of the client is that split. Platform, gym owner, staff, and member each get their own workspace. The schedule is the day-to-day view — coaches side by side, visits on an active membership — not a generic admin grid.

---

## Portals

**Platform** — invite gyms, list and cancel them  
**Gym owner** — staff, members, memberships, visits  
**Staff** — own schedule, resolve and void visits  
**Member** — own profile and visits  

---

## Tech stack

| Layer | Technologies |
|--------|----------------|
| App | Flutter · Dart |
| Web | Flutter web |
| API | FitCore (.NET) over HTTPS |

---

## Run

Needs the API running locally (see [FitCore](https://github.com/davidzdravkovic/FitCore)).

```bash
flutter pub get
flutter run -d chrome
```

---

## License

Personal portfolio project. Ask before reusing commercially.
