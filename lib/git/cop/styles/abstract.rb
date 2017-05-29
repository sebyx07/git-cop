# frozen_string_literal: true

require "refinements/strings"

module Git
  module Cop
    module Styles
      # An abstract class which provides basic functionality from which all style cops inherit from.
      # Not meant for direct use.
      class Abstract
        using Refinements::Strings

        def self.id
          to_s.sub("Git::Cop::Styles", "").snakecase.to_sym
        end

        def self.defaults
          fail NotImplementedError, "The `.defaults` method has not been implemented."
        end

        def self.descendants
          (Git::Cop::Styles.constants - [:Abstract]).map do |klass|
            Git::Cop::Styles.const_get klass
          end
        end

        def initialize commit:, settings: self.class.defaults
          @commit = commit
          @settings = settings
        end

        def sha
          commit.sha
        end

        def enabled?
          settings.fetch :enabled
        end

        def valid?
          fail NotImplementedError, "The `#valid?` method has not been implemented."
        end

        def error
          fail NotImplementedError, "The `#error` method has not been implemented."
        end

        protected

        attr_reader :commit, :settings
      end
    end
  end
end