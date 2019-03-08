#!/usr/bin/env ruby

require 'pry'
require 'mysql2'
require 'tty-spinner'
require_relative 'lib/songs_db'

def spinner
  TTY::Spinner.new(spinner_options)
end

def spinner_options
  { format: :dots,
    interval: 6,
    hide_cursor: true }
end

system 'clear'
puts 'Scanning for broken tracks...'

# spinner.auto_spin

history = SongsDb.new.historylist
track_hash = {}
history.each do |track|
  details = { id: track['songID'],
              date_played: track['date_played'],
              title: track['title'],
              artist: track['artist'] }
  track_hash[track['ID']] = details
end

broken_tracks = []
track_hash.each do |t|
  id = t.first
  current_track = t.last
  next_track = track_hash[id + 1]
  next unless next_track
  duration = next_track[:date_played] - current_track[:date_played]
  next if duration.negative? || duration > 1
  details = "#{current_track[:id]}: #{current_track[:artist]} - " \
            "#{current_track[:title]}"
  broken_tracks << details
end

occurences = Hash.new 0
broken_tracks.each do |track|
  occurences[track] += 1
end

occurences.sort_by(&:last).reverse.each do |track, total|
  puts "[#{total}x] #{track}"
end
