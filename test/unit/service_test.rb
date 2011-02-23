require 'test_helper'

class ServiceTest < ActiveSupport::TestCase
  def test_finders
    s = Service.all
    assert_equal 3, s.size
    s = Service.first
    assert "http", s.name
    assert "http", s.proto
    assert 80, s.port
    assert "open", s.state
    assert s.exploited?

    s = Service.last
    assert "ftp", s.name
    assert "ftp", s.proto
    assert 21, s.port
    assert "open", s.state
    assert s.exploited?
  end
end
