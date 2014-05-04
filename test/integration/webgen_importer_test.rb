require 'test_helper'

class WebgenImporterTest < ActiveSupport::TestCase
  require 'import_webgen_yaml'

  test "should find shortest path" do
    finder = Import::BasePathFinder.new
    finder << '/srv/www/media/event/format/image'
    finder << '/srv/www/media/event/other/image'
    finder << '/srv/www/media/event/image'
    assert_equal '/srv/www/media/event', finder.base 
  end

  test "should find shortest path again" do
    finder = Import::BasePathFinder.new
    finder << '/media/congress/2001/creative/18c3_final_divx.gif'
    finder << '/media/congress/2001/video/vortraege/tag2/saal2/Blinkenlights_isdn.gif'
    assert_equal '/media/congress/2001', finder.base 
  end

  test "should find a valid path" do
    finder = Import::BasePathFinder.new
    finder << '/media/congress/2001/vids/18c3_final_divx.gif'
    finder << '/media/congress/2001/video/vortraege/tag2/saal2/Blinkenlights_isdn.gif'
    assert_equal '/media/congress/2001', finder.base 
  end

  test "should stay inside event" do
    finder = Import::BasePathFinder.new
    finder << '/srv/www/media/event/image1'
    finder << '/srv/www/media/event/image2'
    assert_equal '/srv/www/media/event', finder.base 
  end
end
