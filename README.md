# Subject Manager

[![CI](https://github.com/taras-tyshko/subject_manager/actions/workflows/ci.yml/badge.svg)](https://github.com/taras-tyshko/subject_manager/actions)

A Phoenix LiveView application for managing football players (subjects) with advanced filtering, detailed profiles, and full CRUD administration capabilities.

**Tech Stack:** Elixir 1.17.3 • Phoenix 1.7.14 • LiveView 1.0.5 • SQLite3 • Tailwind CSS

## Features

### 🔍 Smart Filtering & Search
- **Real-time search** by player name
- **Filter by position**: Forward, Midfielder, Winger, Defender, Goalkeeper
- **Advanced sorting**: Sort by name, team, or position with ASC/DESC toggle
- **URL-based state**: All filters persist in URL for easy sharing

### 📊 Subject Management
- **Card view**: Beautiful grid layout showing player photos, names, teams, and positions
- **Detailed profiles**: Individual pages with full biography and statistics
- **Responsive design**: Works seamlessly on desktop and mobile devices

### ⚙️ Admin Panel
- **Complete CRUD operations**: Create, Read, Update, Delete subjects
- **Table-based interface**: Easy-to-scan list of all subjects
- **Confirmation dialogs**: Safety checks before deletion
- **Flash notifications**: Success/error feedback for all operations
- **Form validation**: Comprehensive validation with helpful error messages

## Getting Started

### Installation

**Recommended:** Use [asdf](https://asdf-vm.com) to install all dependencies:

```bash
# Install Elixir, Erlang, and Node.js (versions defined in .tool-versions)
asdf install

# Setup project
mix setup

# Start the server
mix phx.server
```

Visit **http://localhost:4000** to see the application.

## Usage Guide

### Public Interface

**Homepage** (`/`)
- Browse all subjects in a card-based grid
- Use the search box to filter by name
- Select a position from the dropdown to filter
- Choose a sort field and toggle between ascending/descending order
- Click "Reset" to clear all filters
- Click any card to view detailed information

**Subject Details** (`/subjects/:id`)
- View full player profile with photo
- Read complete biography
- See team and position information
- Navigate back to the main list

### Admin Interface

**Admin Panel** (`/admin`)
- View all subjects in a table format
- Click "Add New Subject" to create a new entry
- Click "Edit" next to any subject to modify it
- Click "Delete" to remove a subject (with confirmation)
- Use "Back to Public View" to return to the homepage

**Creating/Editing Subjects**
Required fields:
- **Name**: Player's full name (minimum 3 characters)
- **Team**: Current team name
- **Position**: One of: Forward, Midfielder, Winger, Defender, Goalkeeper
- **Bio**: Player biography (minimum 10 characters)
- **Image Path**: Path to player photo (e.g., `/images/player-name.jpg`)

## Project Structure

```
lib/
├── subject_manager/
│   ├── subjects/
│   │   └── subject.ex          # Subject schema and validations
│   ├── subjects.ex             # Business logic context
│   └── repo.ex                 # Database repository
├── subject_manager_web/
│   ├── live/
│   │   ├── subject_live/
│   │   │   ├── index.ex        # Main listing page with filters
│   │   │   └── show.ex         # Subject detail page
│   │   └── admin_live/
│   │       ├── index.ex        # Admin panel with table
│   │       └── form.ex         # Create/Edit form page
│   ├── components/
│   │   ├── core_components.ex  # Phoenix default components
│   │   └── custom_components.ex   # Custom badge component
│   └── router.ex               # Application routes
assets/
└── css/
    └── app.css                 # Tailwind CSS styles
priv/
├── repo/
│   ├── migrations/             # Database migrations
│   └── seeds.exs               # Sample data
└── static/
    └── images/                 # Player photos
```

## Database Schema

**subjects** table:
- `id` (primary key)
- `name` (string) - Player's full name
- `team` (text) - Current team
- `position` (enum) - One of: forward, midfielder, winger, defender, goalkeeper
- `bio` (string) - Player biography
- `image_path` (string) - Path to photo
- `inserted_at` (utc_datetime)
- `updated_at` (utc_datetime)

## Development

### Running Tests

```bash
# Run with coverage report
mix test --cover
```

### Code Quality

```bash
# Check formatting
mix format --check-formatted

# Compile with warnings as errors
mix compile --warnings-as-errors
```

## Continuous Integration

This project uses GitHub Actions for CI/CD:

- ✅ Automated testing on every push/PR
- ✅ Code formatting checks
- ✅ Compilation with warnings as errors
- ✅ Test coverage reporting
- ✅ Dependency checks

See `.github/workflows/ci.yml` for configuration details.

## Implementation Notes

### Key Features Implemented

✅ **Step 1**: Project setup and exploration  
✅ **Step 2**: Filtering and sorting functionality  
✅ **Step 3**: Subject detail pages  
✅ **Step 4**: Admin CRUD interface  
✅ **Step 5**: GitHub repository and CI/CD  

### Design Decisions

1. **LiveView over JavaScript**: Real-time updates without complex frontend frameworks
2. **URL-based state**: Filters persist in URL for easy bookmarking and sharing
3. **Dedicated form pages**: Create/edit operations on separate pages for clarity
4. **Confirmation dialogs**: Browser confirms for destructive actions (delete)
5. **SQLite for development**: Lightweight database for easy setup
6. **Tailwind CSS**: Utility-first styling for rapid development
7. **Comprehensive testing**: 152 tests with 78.81% code coverage

### Test Coverage

- ✅ **100%** coverage on all LiveView modules
- ✅ **100%** coverage on Subject schema and validations
- ✅ **95.83%** coverage on Subjects context
- ✅ **152 tests** total (unit, integration, LiveView)

## License

This project is part of an interview assessment.
