module FahrplanParser
  class FahrplanParser
    require "rexml/document"

    def initialize(xml)
      @xml = xml
      @doc = REXML::Document.new @xml
    end

    def events_by_guid
      @events = Hash.new { |h,e| h[e] = Hash.new }
      @doc.elements.each("schedule/day/room/event") { |ev|
        guid = ev.attributes['guid']
        persons = []
        ev.elements['persons'].each_element { |p|
          persons << p.text
        }
        @events[guid] = {
          title:       ev.elements['title'].text,
          description: ev.elements['abstract'].text || ev.elements['description'].text,
          tags:        [ev.elements['track'].text],
          date:        ev.parent.parent.attributes['date'],
          subtitle:    ev.elements['subtitle'].text,
          persons:     persons
        }
      }
      @events
    end

  end
end
