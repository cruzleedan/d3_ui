/// Shared visual status for d3_ui input fields — idle/focused/filled/error/
/// success/disabled. Extracted from D3TextField's private `_FieldStatus` so
/// [D3FieldStylingMixin] can resolve colors the same way across fields.
enum D3FieldStatus { idle, focused, filled, error, success, disabled }
