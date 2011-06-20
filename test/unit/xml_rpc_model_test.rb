require 'test_helper'

class XMLRpcModelTest < ActiveSupport::TestCase
#  def test_xml_parser
#    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
#    <host>
#    <id type=\"integer\">1</id>
#    <ip>locahost</ip>
#    <name>wurst</name>
#    </host>"
#    res = Host.parse_xml(xml)
#    assert "Host",res.class.to_s
#    #assert "localhost",res.ip 
#    assert "wurst",res.name 

#    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
#    <host>
#    <id type=\"integer\">1</id>
#    <ip>localhost</ip>
#    <name></name>
#    </host>"
#    res = Host.parse_xml(xml)
#    assert_equal "Host",res.class.to_s
#    #assert_equal "localhost",res.ip 
#    assert_equal nil,res.name 
#  end

#  def test_xml_parser_for_collection
#    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
#    <fidius-asset-hosts type=\"array\">
#      <fidius-asset-host>
#        <id type=\"integer\">1</id>
#        <ip>locahost</ip>
#        <name>wurst</name>
#      </fidius-asset-host>
#      <fidius-asset-host>
#        <id type=\"integer\">2</id>
#        <ip>70.60.40.30</ip>
#        <name>horst</name>
#      </fidius-asset-host>
#    </fidius-asset-hosts>"
#    res = Host.parse_xml(xml)
#    assert_equal 2,res.size
#  end

#  def test_not_implemented
#    h = Host.new
#    assert_raises RuntimeError do
#      h.save
#    end
#    assert_raises RuntimeError do
#      h.update
#    end
#    assert_raises RuntimeError do
#      h.create
#    end
#    assert_raises RuntimeError do
#      h.delete
#    end
#    assert_raises RuntimeError do
#      h.destroy
#    end
#    assert_raises RuntimeError do
#      Host.find_by_sql("does not matter")
#    end
#  end

#  def test_connection
#    conn = FIDIUS::XmlRpcModel.connect
#    assert conn
#    assert_equal XMLRPC::Client,conn.class

#    # TODO: can not test overwritten method...
#    # HOW TO OVERWRITE class method ???
#    #Host.old_call_rpc("doesnt matter","dosnt matter")
#    
#  end
end

