module Spec
  module Matchers

    class OperatorMatcher
      @operator_registry = {}

      def self.register(klass, operator, matcher)
        @operator_registry[klass] ||= {}
        @operator_registry[klass][operator] = matcher
      end

      def self.get(klass, operator)
        return @operator_registry[klass][operator] if @operator_registry[klass]
        nil
      end
    end

    class BaseOperatorMatcher
      def initialize(given)
        @given = given
      end

      def self.use_custom_matcher_or_delegate(operator)
        define_method(operator) do |expected|
          if matcher = OperatorMatcher.get(@given.class, operator)
            return @given.send(matcher_method, matcher.new(expected))
          else
            __delegate_method_missing_to_given(operator, expected)
          end
        end
      end

      ['==', '===', '=~', '>', '>=', '<', '<='].each do |operator|
        use_custom_matcher_or_delegate operator
      end

      def fail_with_message(message)
        Spec::Expectations.fail_with(message, @expected, @given)
      end

      def description
        "#{@operator} #{@expected.inspect}"
      end

    end

    class PositiveOperatorMatcher < BaseOperatorMatcher #:nodoc:
      def matcher_method
        :should
      end

      def __delegate_method_missing_to_given(operator, expected)
        @expected = expected
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true if @given.__send__(operator, expected)
        return fail_with_message("expected: #{expected.inspect},\n     got: #{@given.inspect} (using #{operator})") if ['==','===', '=~'].include?(operator)
        return fail_with_message("expected: #{operator} #{expected.inspect},\n     got: #{operator.gsub(/./, ' ')} #{@given.inspect}")
      end

    end

    class NegativeOperatorMatcher < BaseOperatorMatcher #:nodoc:
      def matcher_method
        :should_not
      end

      def __delegate_method_missing_to_given(operator, expected)
        @expected = expected
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true unless @given.__send__(operator, expected)
        return fail_with_message("expected not: #{operator} #{expected.inspect},\n         got: #{operator.gsub(/./, ' ')} #{@given.inspect}")
      end

    end

  end
end
