class UpdateRelatedEvents
  def initialize
    @graph = {}
  end

  def update
    related = related_by_views

    build_graph(related)

    update_related
  end

  private

  def update_related
    @graph.each { |id, edges|
      event = Recording.find(id).event
      next unless event
      sorted = Hash[edges.sort_by { |_, v| -v }]
      new_event_ids = sorted.keys.map { |recording_id|
        event_id = Recording.find(recording_id).event.id
        next unless event_id
        event_id
      }.compact
      event.metadata['related'] ||= []
      event.metadata['related'] += new_event_ids
      event.save
    }
  end

  def build_graph(related)
    related.each { |events|
      events.each { |event|
        node = if @graph.key?(event)
                 @graph[event]
               else
                 @graph[event] = Hash.new { |h, v| h[v] = 0 }
               end

        (events-[event]).each { |v| node[v] +=1 }
      }
    }

    @graph.each do |_id, edges|
      weights = edges.values
      next if weights.count < 2
      limit = percentile(weights, 0.95)
      edges.delete_if { |_k, v| v < limit.to_i }
    end
  end

  def related_by_views
    views = RecordingView.connection.execute(%{
        SELECT array_agg(recording_id) as recording_group
          FROM recording_views
         GROUP BY identifier, user_agent
    })
    views.values.map { |group| group.first[1..-2].split(/,/) }
  end

  def percentile(values, percentile)
    values_sorted = values.sort
    k = (percentile * (values_sorted.length - 1) + 1).floor - 1
    f = (percentile * (values_sorted.length - 1) + 1).modulo(1)

    values_sorted[k] + (f * (values_sorted[k + 1] - values_sorted[k]))
  end
end
