json.partial! 'public/shared/event', event: @event
json.recordings @event.recordings, partial: 'public/shared/recording', as: :recording
