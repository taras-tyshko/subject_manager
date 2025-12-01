Subject: Questions Regarding Subject Manager Interview Task

Hi Desi,

Thank you for providing the interview task. I've reviewed the codebase and started planning the implementation. Before proceeding, I'd like to clarify a few things:

## 🐛 Issues Found in the Existing Code

While analyzing the project, I discovered a bug in `lib/subject_manager/subjects/subject.ex`:

**Lines 16 and 21:**
- The changeset function parameter is named `incident` instead of `subject`
- The validation references field `:description` which doesn't exist in the schema (should be `:bio`)

```elixir
# Current code (lines 16-22):
def changeset(incident, attrs) do
  incident
  |> cast(attrs, [:name, :team, :position, :bio, :image_path])
  |> validate_required([:name, :team, :position, :bio, :image_path])
  |> validate_length(:name, min: 3)
  |> validate_length(:description, min: 10)  # ← :description doesn't exist
end
```

**Question:** May I fix these bugs before implementing the new features?

## ❓ Clarification Questions

### 1. Step 4 - Admin Page Structure

**Question:** For the admin CRUD functionality, should I create:
- A separate `/admin` page with a table and action buttons, OR
- Add edit/delete buttons directly on the main subject cards page?

### 2. Image Handling in Forms

**Question:** For the add/edit subject form, how should I handle images:
- Simple text input field for image path (simpler approach), OR
- Full image upload functionality (requires additional library like Arc/Waffle)?

---

I'm ready to start implementation as soon as these points are clarified. Please let me know your preferences.

Best regards,
[Your Name]

