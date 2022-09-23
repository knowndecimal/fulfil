# frozen_string_literal: true

module CustomAssertions
  # Inverse of `assert_mock` as Minitest doesn't implement this themselves.
  # @param mock [Minitest::Mock]
  # @return [true, false]
  def refute_mock(mock)
    assert_raises(MockExpectationError) { mock.verify }
  end
end
