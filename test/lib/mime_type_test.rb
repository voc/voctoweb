require 'test_helper'

class MimeTypeTest < ActiveSupport::TestCase
  test 'humanized returns correct slug for video/mp4' do
    assert_equal 'mp4', MimeType.humanized('video/mp4')
  end

  test 'humanized returns correct slug for video/webm' do
    assert_equal 'webm', MimeType.humanized('video/webm')
  end

  test 'humanized returns correct slug for video/webm with AV1 codec' do
    assert_equal 'av1', MimeType.humanized('video/webm;codecs=av01')
  end

  test 'humanized returns correct slug for video/ogg' do
    assert_equal 'ogg', MimeType.humanized('video/ogg')
  end

  test 'humanized returns correct slug for audio/mpeg' do
    assert_equal 'mp3', MimeType.humanized('audio/mpeg')
  end

  test 'humanized returns correct slug for audio/opus' do
    assert_equal 'opus', MimeType.humanized('audio/opus')
  end

  test 'humanized returns correct slug for application/x-subrip' do
    assert_equal 'srt', MimeType.humanized('application/x-subrip')
  end

  test 'humanized returns correct slug for text/vtt' do
    assert_equal 'vtt', MimeType.humanized('text/vtt')
  end

  test 'humanized returns correct slug for application/dash+xml' do
    assert_equal 'mpd', MimeType.humanized('application/dash+xml')
  end

  test 'humanized returns correct slug for application/vnd.apple.mpegurl' do
    assert_equal 'hls', MimeType.humanized('application/vnd.apple.mpegurl')
  end

  test 'humanized returns correct slug for application/pdf' do
    assert_equal 'pdf', MimeType.humanized('application/pdf')
  end

  test 'humanized falls back to second part of mime type for unknown types' do
    assert_equal 'unknown', MimeType.humanized('application/unknown')
  end

  test 'display returns correct name for video/mp4' do
    assert_equal 'MP4', MimeType.display('video/mp4')
  end

  test 'display returns correct name for video/webm' do
    assert_equal 'WebM', MimeType.display('video/webm')
  end

  test 'display returns correct name for video/webm with AV1 codec' do
    assert_equal 'AV1', MimeType.display('video/webm;codecs=av01')
  end

  test 'display returns correct name for video/ogg' do
    assert_equal 'Ogg', MimeType.display('video/ogg')
  end

  test 'display returns correct name for audio/mpeg' do
    assert_equal 'MP3', MimeType.display('audio/mpeg')
  end

  test 'display returns correct name for audio/opus' do
    assert_equal 'Opus', MimeType.display('audio/opus')
  end

  test 'display returns correct name for application/x-subrip' do
    assert_equal 'SRT', MimeType.display('application/x-subrip')
  end

  test 'display returns correct name for text/vtt' do
    assert_equal 'WebVTT', MimeType.display('text/vtt')
  end

  test 'display returns correct name for application/dash+xml' do
    assert_equal 'mpd', MimeType.display('application/dash+xml')
  end

  test 'display returns correct name for application/vnd.apple.mpegurl' do
    assert_equal 'hls', MimeType.display('application/vnd.apple.mpegurl')
  end

  test 'display returns correct name for application/pdf' do
    assert_equal 'PDF', MimeType.display('application/pdf')
  end

  test 'display falls back to capitalized second part of mime type for unknown types' do
    assert_equal 'Unknown', MimeType.display('application/unknown')
  end
end
