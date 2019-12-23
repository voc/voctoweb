module FahrplanParser
  class FahrplanParser
    require "rexml/document"

    def initialize(xml)
      @xml = xml
      @doc = REXML::Document.new @xml
    end

    def event_info_by_guid
      @events = Hash.new { |h,e| h[e] = Hash.new }
      @doc.elements.each("schedule/day/room/event") { |ev|
        guid = ev.attributes['guid']
        @events[guid] = {
          id:          ev.attributes['id'],
          title:       ev.elements['title'].text,
          description: ev.elements['abstract'].text || ev.elements['description'].text,
          tags:        [ev.elements['track'].text].compact,
          date:        get_event_date(ev),
          subtitle:    ev.elements['subtitle'].text,
          slug:        ev.elements['slug'].text,
          link:        (ev.elements['url'].text unless ev.elements['url'].nil?),
          persons:     get_persons(ev)
        }
      }
      @events
    end

    private

    def get_event_date(ev)
      if ev.elements['date']
        # new schedule xml
        "#{ev.elements['date'].text} #{ev.elements['start'].text}"
      else
        # old schedule xml: use conference date
        ev.parent.parent.attributes['date']
      end
    end

    def get_persons(ev)
      persons = []
      ev.elements['persons'].each_element { |p|
        persons << p.text
      }
      persons
    end

  end
end
