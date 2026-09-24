# Application-specific R8 rules.
# Keep this file intentionally conservative: release builds must not rely on
# broad keep rules that hide dead code or weaken shrinking.
# Add a narrowly scoped rule only with a documented runtime requirement.
