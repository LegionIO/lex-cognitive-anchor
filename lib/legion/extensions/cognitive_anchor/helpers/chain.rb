# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAnchor
      module Helpers
        class Chain
          attr_reader :id, :anchor_id, :material, :created_at
          attr_accessor :length, :flexibility

          def initialize(anchor_id:, material: :steel, length: nil, flexibility: nil)
            validate_material!(material)
            @id          = SecureRandom.uuid
            @anchor_id   = anchor_id
            @material    = material.to_sym
            @length      = (length || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @flexibility = (flexibility || material_flexibility).to_f.clamp(0.0, 1.0).round(10)
            @created_at  = Time.now.utc
          end

          def extend!(amount: 0.1)
            @length = (@length + amount.abs).clamp(0.0, 1.0).round(10)
          end

          def shorten!(amount: 0.1)
            @length = (@length - amount.abs).clamp(0.0, 1.0).round(10)
          end

          def wear!(rate: 0.05)
            @flexibility = (@flexibility - rate.abs).clamp(0.0, 1.0).round(10)
          end

          def broken?
            @flexibility < Constants::BREAK_THRESHOLD
          end

          def elastic?
            @flexibility >= 0.8
          end

          def rigid?
            @flexibility < 0.2
          end

          def short?
            @length < 0.3
          end

          def long?
            @length >= 0.7
          end

          def flexibility_label
            Constants.label_for(Constants::FLEXIBILITY_LABELS, @flexibility)
          end

          def to_h
            {
              id:               @id,
              anchor_id:        @anchor_id,
              material:         @material,
              length:           @length,
              flexibility:      @flexibility,
              flexibility_label: flexibility_label,
              broken:           broken?,
              elastic:          elastic?,
              created_at:       @created_at
            }
          end

          private

          def validate_material!(val)
            return if Constants::CHAIN_MATERIALS.include?(val.to_sym)

            raise ArgumentError,
                  "unknown material: #{val.inspect}; " \
                  "must be one of #{Constants::CHAIN_MATERIALS.inspect}"
          end

          def material_flexibility
            { steel: 0.3, rope: 0.6, wire: 0.4, thread: 0.8, cobweb: 0.9 }
              .fetch(@material, 0.5)
          end
        end
      end
    end
  end
end
