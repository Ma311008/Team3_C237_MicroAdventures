# Micro-Adventures — C237 CA2 (Team 3)

A local micro-adventure bucket list app. Admins curate a list of local experiences (food, nature,
culture, nightlife, shopping); explorers browse them, mark ones as completed with a rating/notes,
and track their progress — including simple category badges for completing 5+ experiences in the
same category.

Built with Node.js, Express, EJS, and MySQL (`mysql2`), following the patterns from L19-L20
(sessions, flash messages, role-based access middleware) plus the CRUD patterns used throughout
the module.

## Setup

1. Clone and install:
   ```
   git clone https://github.com/Ma311008/Team3_C237_MicroAdventures.git
   cd Team3_C237_MicroAdventures
   npm install
   ```
2. Create the database — run `schema.sql` in MySQL (creates `c237_adventuredb` and seeds one
   admin account: `admin@adventure.com` / `admin123`).
3. Check the DB credentials in `app.js` (`mysql.createConnection({...})`) match your local MySQL
   setup (default: `root` with no password).
4. Start the app:
   ```
   npm start
   ```
   Visit `http://localhost:3000`.

## Project structure

```
app.js              All routes (grouped by owner, see below)
schema.sql           Database schema + seed admin account
views/               EJS templates (flat, matches lesson convention)
  partials/navbar.ejs
public/              Static assets
```

## Route map — who owns what

Each feature owner should read their section in `app.js` (marked with a `STUDENT X:` comment
header) plus the matching view file(s), understand it, and be ready to explain the full flow
(user action → route → SQL query → database → response) in the presentation. Don't just copy —
modify it, and know it well enough to answer questions live.

| Owner | Routes | Feature | Views |
|---|---|---|---|
| **A** | `GET/POST /register`, `GET/POST /login`, `GET /logout` | Registration, login, access control | `register.ejs`, `login.ejs` |
| **B** | `GET /experiences/new`, `POST /experiences`, `POST /experiences/:id/complete` | Adding new experiences (admin) + marking one complete (explorer) | `addExperience.ejs` |
| **C** | `GET /explore`, `GET /experiences/:id`, `GET /my-progress` | Browsing, detail view, personal dashboard (+ badges) | `explore.ejs`, `experienceDetail.ejs`, `myProgress.ejs` |
| **D** | `GET/POST /experiences/:id/edit`, `GET/POST /completions/:id/edit` | Editing experiences (admin) + editing your own completion entry | `editExperience.ejs`, `editCompletion.ejs` |
| **E** | `POST /experiences/:id/delete`, `POST /completions/:id/delete`, `GET /search` | Deleting records + search/filter/sort | (renders `explore.ejs`) |

## Roles

- **admin** — manages the master list of experiences (add/edit/delete), seeded account:
  `admin@adventure.com` / `admin123`
- **explorer** — default role on self-registration; browses experiences, marks them complete,
  manages their own completion entries

## Workflow

- Work on a feature branch per person (`git checkout -b feature/your-name`), open a PR into
  `master` so the team can review before merging.
- `app.js` is shared — coordinate before editing someone else's section to avoid merge conflicts.
- Remember to fill in the CA2 Team Development Journal (Section C: Team Contribution Record) as
  you go.
