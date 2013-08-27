FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :event_title do |n|
    "some event#{n}"
  end

  sequence :tags do |n|
    "tags#{n}"
  end

  factory :api_key do
    key "4"
    description "key"
  end

  factory :conference do
    acronym { generate(:conference_acronym) }
    title "FrabCon"
    recordings_path "events/frabcon123"
    images_path "frabcon123"
    webgen_location "conference/frabcon123"
    aspect_ratio "16:9"
    schedule_url "schedule.xml"
    schedule_state "downloaded"
  end

  factory :event do
    conference
    event_info
    guid "testGUID"
    title { generate(:event_title) }
    thumb_filename "frabcon123.jpg"
    gif_filename "frabcon123.gif"
    poster_filename "frabcon123_logo.jpg"
  end

  factory :event_info do
    subtitle "subtitle"
    slug "slug"
    link "http://localhost"
    description "description"
    persons ["Name"]
    tags ["tag"]
    date "2013-08-21"
  end

  factory :recording do
    event
    filename "audio.mp3"
    mime_type "audio/mpeg"
    original_url "http://vhost2.hansenet.de/1_mb_file.bin"
    size "12"
    length "5"
    state "new"
  end

end
