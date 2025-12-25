#!/usr/bin/env ruby
require_relative "../config/environment"

Registration.all.group_by { |r| [ r.tournament_id, r.email ] }.each do |k, potential_rg|
  potential_rg.group_by { |r| r.participants.map { |p| p.club }.first }.each do |club, rg|
    next if rg.length <= 1
    puts "Combining registration for '#{Tournament.find(k[0]).name}'-'#{club}'-#{k[1]}"
    Registration.transaction do
      combined_comment = rg.map { |r| r.comment }.filter { |s| !s.blank? }.join("\n")
      rg.first.comment = combined_comment
      puts "Comment:".indent(2) unless combined_comment.blank?
      puts combined_comment.indent(4) unless combined_comment.blank?

      all_participants = rg.map { |r| r.participants }.flatten
      rg.first.participants = all_participants
      puts "Participants:".indent(2)
      puts all_participants.map { |p| "#{p.first_name} #{p.last_name}" }.join("\n").indent(4)

      rg.first.save
      rg[1..].each(&:destroy!)
    end
  end
end
