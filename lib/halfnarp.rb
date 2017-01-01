# frozen_string_literal: true
graph = {}
votes = JSON.parse(File.read('votes.json'))

votes.each { |vote|
  next if vote.count < 2
  vote.each { |event|
    print '.'
    node = if graph.key?(event)
             graph[event]
           else
             graph[event] = Hash.new { |h, v| h[v] = 0 }
           end

    (vote - [event]).each { |v|
      node[v] += 1
    }
  }
}
puts

def percentile(values, percentile)
  values_sorted = values.sort
  k = (percentile * (values_sorted.length - 1) + 1).floor - 1
  f = (percentile * (values_sorted.length - 1) + 1).modulo(1)

  values_sorted[k] + (f * (values_sorted[k + 1] - values_sorted[k]))
end

graph.each { |_id, edges|
  weights = edges.values
  next if weights.count < 2
  limit = percentile(weights, 0.95)
  edges.delete_if { |_k, v| v < limit.to_i }
}

def find_event(conference, id)
  conference.events.find_by('metadata @> ?', { remote_id: id.to_s }.to_json)
end

conference = Conference.find_by(acronym: '33c3')
graph.each { |id, edges|
  event = find_event(conference, id)
  next unless event
  sorted = Hash[edges.sort_by { |_, v| -v }]
  event.metadata[:related] = sorted.keys.map { |event_id|
    find_event(conference, event_id)
  }.compact.map(&:id)
  event.save
}
