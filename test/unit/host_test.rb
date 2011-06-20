require 'test_helper'

class HostTest < ActiveSupport::TestCase
#  def test_finders
#    h = Host.all
#    assert_equal 5, h.size
#    h = Host.first
#    assert h.has_ip? "192.168.178.1"
#    assert !h.exploited?
#    assert_equal "windows", h.os_name
#    assert_equal "SP2", h.os_sp
#  end

  def test_image
    h = Host.new
    assert_equal "unknownpc.png",h.image

    h = Host.find(3)
    p h.sessions
    assert_equal "unknownpc_hacked.png",h.image

    h = Host.find(4)
    p h.sessions
    assert_equal "windowsxp_hacked.png",h.image

    h = Host.find(5)
    p h.sessions
    assert_equal "windowsxp.png",h.image
  end
end
