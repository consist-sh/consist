require "test_helper"

class ConsistTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Consist::VERSION
  end
end
