require 'test_helper'

class HostTest < ActiveSupport::TestCase
  def test_finders
    h = Host.all
    assert_equal 3, h.size
    h = Host.first
    assert_equal "192.168.178.1", h.ip
    assert_equal "192.168.178.1", h.address
    assert !h.exploited?
    assert_equal "windows", h.os_name
    assert_equal "SP2", h.os_sp
  end

  def test_image
    h = Host.new
    assert_equal "unknownpc.png",h.image

    h = Host.new(:exploited=>true)
    assert_equal "unknownpc_hacked.png",h.image

    h = Host.new(:exploited=>true,:os_name=>"windows")
    assert_equal "windowsxp_hacked.png",h.image

    h = Host.new(:exploited=>false,:os_name=>"windows")
    assert_equal "windowsxp.png",h.image
  end
end
