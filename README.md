# Subject Manager

[![CI](https://github.com/YOUR_USERNAME/elixir_liveview_interview/workflows/CI/badge.svg)](https://github.com/YOUR_USERNAME/elixir_liveview_interview/actions)

A Phoenix LiveView application for managing football players (subjects) with advanced filtering, detailed profiles, and full CRUD administration capabilities.

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

## Technology Stack

- **Elixir** 1.17.2 / OTP 26
- **Phoenix Framework** 1.7.14
- **Phoenix LiveView** 1.0.0-rc.1 - Real-time interactivity without JavaScript
- **Ecto** 3.10 with SQLite3 - Database management
- **Tailwind CSS** 0.2 - Modern, utility-first styling
- **esbuild** 0.8 - Asset bundling

## Prerequisites

### Required Software

1. **ASDF** (recommended) or manual installation of:
   - Erlang 26.2.5
   - Elixir 1.17.2
   - Node.js 23.6.1

### Install ASDF (macOS)

```bash
brew install asdf
```

For other platforms, see [ASDF installation guide](https://asdf-vm.com/guide/getting-started.html).

## Setup Instructions

### 1. Install Language Versions

```bash
# Add ASDF plugins
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add nodejs

# Install versions (defined in .tool-versions)
asdf install
```

### 2. Install Dependencies & Setup Database

```bash
# Install Elixir dependencies and setup database
mix setup
```

This command will:
- Install all dependencies
- Create the database
- Run migrations
- Seed the database with sample data (12 football players)

### 3. Start the Server

```bash
# Start Phoenix server
mix phx.server

# Or start with interactive Elixir shell
iex -S mix phx.server
```

The application will be available at **http://localhost:4000**

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
│   │       └── form_component.ex  # Create/Edit form
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
# Run all tests
mix test

# Run with coverage report
mix test --cover
```

### Code Quality

```bash
# Format code
mix format

# Check formatting
mix format --check-formatted

# Compile with warnings as errors
mix compile --warnings-as-errors
```

### Database Operations

```bash
# Reset database (drop, create, migrate, seed)
mix ecto.reset

# Create a new migration
mix ecto.gen.migration migration_name

# Run migrations
mix ecto.migrate

# Rollback last migration
mix ecto.rollback
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

1. **LiveView over JavaScript**: Chose Phoenix LiveView for real-time updates without complex frontend frameworks
2. **URL-based state**: Filters persist in URL parameters for bookmarking and sharing
3. **Modal forms**: Edit/create operations use modals for better UX
4. **Confirmation dialogs**: Native browser confirms for destructive actions
5. **SQLite for development**: Lightweight database for easy local development
6. **Tailwind CSS**: Utility-first styling for rapid development

### Known Limitations

- No authentication system (admin panel is publicly accessible)
- No image upload functionality (image paths must be provided manually)
- SQLite database (suitable for development, consider PostgreSQL for production)
- No pagination (works well with current dataset size)

## Production Deployment

For production deployment, consider:

1. Switch to PostgreSQL database
2. Add authentication/authorization for admin panel
3. Implement image upload functionality
4. Add pagination for large datasets
5. Configure proper environment variables
6. Set up SSL/HTTPS
7. Configure production secret key base

See [Phoenix deployment guide](https://hexdocs.pm/phoenix/deployment.html) for more details.

## License

This project is part of an interview assessment.

## Contact

For questions or clarifications, please refer to `QUESTIONS_FOR_CLIENT.md`.
