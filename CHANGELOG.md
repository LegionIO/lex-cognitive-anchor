# Changelog

## [0.1.1] - 2026-03-18

### Fixed
- Enforce chain flexibility on bias calculations — `apply_bias` now factors in average chain flexibility when computing bias pull; rigid chains (steel) preserve stronger pull, flexible chains (cobweb) reduce it
- Added `chain_factor` to `apply_bias` return hash for transparency
- Broken chains are excluded from flexibility calculation

## [0.1.0] - 2026-03-13

### Added
- Initial release: cognitive anchoring with grip, drag, drift mechanics
- Five anchor types (belief, assumption, experience, authority, number)
- Five chain materials (steel, rope, wire, thread, cobweb) with flexibility
- Bias pull computation, anchor report, standalone Client
