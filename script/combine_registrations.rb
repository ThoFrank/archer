#!/usr/bin/env ruby
require_relative "../config/environment"

# Drain pending registration emails before running this historical cleanup:
# queued jobs may still reference registrations it deletes.
Registration.find_each do |registration|
  combined = registration.combine_with_existing!
  next if combined == registration

  puts "Combined registration #{registration.id} into #{combined.id} for '#{combined.tournament.name}'-#{combined.email}"
end
