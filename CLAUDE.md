# lex-cognitive-anchor

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Cognitive anchoring and belief tethering — anchor points resist change via grip, chains link anchors with material-dependent flexibility, and bias application models how anchors distort estimates.

## Gem Info

- **Gem name**: `lex-cognitive-anchor`
- **Version**: `0.1.1`
- **Module**: `Legion::Extensions::CognitiveAnchor`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_anchor/
  cognitive_anchor.rb            # Main extension module
  version.rb                     # VERSION = '0.1.0'
  client.rb                      # Client wrapper
  helpers/
    constants.rb                 # Anchor types, chain materials, drag/drift rates, grip/flexibility labels
    anchor.rb                    # Anchor value object (grip, type, domain, age)
    chain.rb                     # Chain value object (material, two anchors, flexibility)
    anchor_store.rb              # AnchorStore — manages anchors and chains, applies bias
  runners/
    cognitive_anchor.rb          # Runner module (extend self) with 6 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
ANCHOR_TYPES = %i[belief assumption experience authority number]
CHAIN_MATERIALS = %i[steel rope wire thread cobweb]
DRAG_RATE = 0.06      # how much grip decays when an anchor is dragged (challenged)
DRIFT_RATE = 0.03     # passive grip decay over time
BREAK_THRESHOLD = 0.1 # grip level at which an anchor breaks (chain severs)
GRIP_LABELS = {
  (0.85..) => :immovable, (0.65...0.85) => :firm, (0.45...0.65) => :moderate,
  (0.25...0.45) => :loose, (..0.25) => :slipping
}
FLEXIBILITY_LABELS = {
  steel: :rigid, rope: :flexible, wire: :semiflexible,
  thread: :very_flexible, cobweb: :fragile
}
```

## Runners

### `Runners::CognitiveAnchor`

Uses `extend self` — methods are module-level, not instance-delegating. Delegates to a per-call `engine` (parameter-injected `Helpers::AnchorStore` instance via `engine:` keyword, defaulting to a shared `@engine ||=`).

- `create_anchor(name:, anchor_type:, domain: :general, grip: 0.7, engine: @engine)` — register an anchor point with initial grip
- `create_chain(anchor_a:, anchor_b:, material:, engine: @engine)` — link two anchors with a chain of specified material; chain flexibility depends on material
- `apply_bias(anchor_id:, estimate:, engine: @engine)` — apply the anchor's distortion to an estimate; returns adjusted estimate and bias magnitude
- `list_anchors(engine: @engine)` — all anchors as array of hashes with grip labels
- `anchor_status(engine: @engine)` — summary: anchor count, chain count, average grip, broken chain count

## Helpers

### `Helpers::AnchorStore`
Core engine managing `@anchors` and `@chains` hashes. `apply_bias` computes how strongly the anchor distorts the given estimate based on current grip. `drag_anchor` reduces grip by `DRAG_RATE`; if grip drops below `BREAK_THRESHOLD`, all chains involving the anchor are severed. `drift_all` applies passive `DRIFT_RATE` decay to all anchors.

### `Helpers::Anchor`
Value object: name, anchor_type, domain, grip (0.0–1.0), age. `drag!` reduces grip by `DRAG_RATE` clamped to 0.0. `drift!` reduces grip by `DRIFT_RATE`. `broken?` returns true when `grip <= BREAK_THRESHOLD`. `grip_label` maps current grip to human-readable label.

### `Helpers::Chain`
Value object: material, anchor_a_id, anchor_b_id, flexibility (derived from material). `flexibility_label` maps material to label from `FLEXIBILITY_LABELS`. `active?` returns true only when neither linked anchor is broken.

## Integration Points

No actor defined — no automatic drift or drag. This extension models how existing beliefs and anchors resist or distort new information. Pairs with lex-anchoring (which models Kahneman/Tversky numeric anchoring and prospect theory) — these are complementary; lex-anchoring covers numeric estimation bias, lex-cognitive-anchor covers structural belief tethering. Pairs with lex-bias (anchor bias detection feeds here) and lex-belief-revision (chain breaks can trigger belief revision events).

## Development Notes

- `extend self` pattern: runner is a module with module-level methods; shared `@engine` lives in the module's singleton
- `BREAK_THRESHOLD = 0.1` is intentionally low — anchors are persistent; they require sustained challenge (`drag_anchor` calls) to break
- `DRAG_RATE (0.06) > DRIFT_RATE (0.03)`: active challenge degrades grip twice as fast as passive time decay
- Chain flexibility modulates bias pull: `chain_factor = 1.0 - (avg_flexibility * 0.5)`, so cobweb chains (0.9 flexibility) reduce pull by 45% while steel chains (0.3) only reduce by 15%; broken chains are excluded
- `apply_bias` returns a hash with both the adjusted estimate and bias magnitude — callers must decide how to apply the adjustment
