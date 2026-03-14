# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_anchor/version'
require_relative 'cognitive_anchor/helpers/constants'
require_relative 'cognitive_anchor/helpers/anchor'
require_relative 'cognitive_anchor/helpers/chain'
require_relative 'cognitive_anchor/helpers/anchor_engine'
require_relative 'cognitive_anchor/runners/cognitive_anchor'
require_relative 'cognitive_anchor/client'

module Legion
  module Extensions
    module CognitiveAnchor
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
