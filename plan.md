# Retro Board Plan

- [x] Generate a Phoenix LiveView project called `retro_board`
- [x] Create detailed plan.md and start the server
- [x] Replace home page with static mockup of clean & minimal design
- [x] Create database migrations for retros and feedback items
  - `retros` table: id, code (unique), title, columns (jsonb), inserted_at, updated_at
  - `feedback_items` table: id, retro_id, column, content, author_name, inserted_at, updated_at
- [x] Implement RetroLive LiveView with real-time updates
  - Handle creating new retro with random code generation
  - Handle joining existing retro by code
  - Handle adding feedback items with PubSub broadcasting
  - Store user name in session for easy re-use
- [x] Create retro_live.html.heex template with clean design
  - Landing page to create/join retro
  - Retro board with Start/Stop/Continue columns
  - Add feedback form for each column
- [x] Implement Retros context for CRUD operations
  - create_retro/1, get_retro_by_code/1, add_feedback_item/3
- [x] Update root.html.heex and app.css to match clean & minimal design
- [x] Update <Layouts.app> component to match design
- [x] Update router - replace home route with retro route
- [x] Visit app to verify everything works
- [x] All steps complete!

