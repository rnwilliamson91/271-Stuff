# Blueprint Standards

## Blueprint vs C++
Use C++ for:
- Core systems
- Replication-sensitive paths
- Shared framework logic

Use Blueprint for:
- Gameplay tuning
- UI behavior
- Event glue logic
- Rapid iteration

## Rules
- No mega-graphs.
- Use function libraries for repeated node chains.
- Keep exposed variables categorized and documented.
- Prefer interfaces over hard casting where possible.
