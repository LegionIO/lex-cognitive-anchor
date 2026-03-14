# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAnchor
      module Runners
        module CognitiveAnchor
          extend self

          def create_anchor(anchor_type:, domain:, content:,
                            reference_value: nil, grip: nil, weight: nil, engine: nil, **)
            eng = resolve_engine(engine)
            a   = eng.create_anchor(anchor_type: anchor_type, domain: domain, content: content,
                                    reference_value: reference_value, grip: grip, weight: weight)
            { success: true, anchor: a.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def create_chain(anchor_id:, material: :steel, length: nil,
                           flexibility: nil, engine: nil, **)
            eng = resolve_engine(engine)
            c   = eng.create_chain(anchor_id: anchor_id, material: material,
                                   length: length, flexibility: flexibility)
            { success: true, chain: c.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def apply_bias(anchor_id:, new_value:, engine: nil, **)
            eng    = resolve_engine(engine)
            result = eng.apply_bias(anchor_id: anchor_id, new_value: new_value)
            { success: true, anchor: result[:anchor].to_h,
              original: result[:original], biased: result[:biased], shift: result[:shift] }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_anchors(engine: nil, anchor_type: nil, **)
            eng     = resolve_engine(engine)
            results = eng.all_anchors
            results = results.select { |a| a.anchor_type == anchor_type.to_sym } if anchor_type
            { success: true, anchors: results.map(&:to_h), count: results.size }
          end

          def anchor_status(engine: nil, **)
            eng = resolve_engine(engine)
            { success: true, report: eng.anchor_report }
          end

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          private

          def resolve_engine(engine)
            engine || default_engine
          end

          def default_engine
            @default_engine ||= Helpers::AnchorEngine.new
          end
        end
      end
    end
  end
end
