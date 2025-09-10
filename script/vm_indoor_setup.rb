#!/usr/bin/env ruby
require_relative "../config/environment"

# Your code goes here
raise "Usage: scripts/vm_indoor_setup.rb tournament_id tournament_name" if ARGV.length != 2
vm = Tournament.find(ARGV[0].to_i)
raise "unexpected tournament name" unless vm.name == ARGV[1]

tfs = [
 { name: "80cm (15m)", distance: 15, size: 80 },
 { name: "80cm", distance: 18, size: 80 },
 { name: "60cm", distance: 18, size: 60 },
 { name: "60cm Spot (6-10 Ring)", distance: 18, size: 60 },
 { name: "40cm", distance: 18, size: 40 },
 { name: "40cm Spot", distance: 18, size: 40 },
 { name: "40cm Vegas Spot", distance: 18, size: 40 }
]

classes = [
 { name: 'Recurve Herren', age_start: 21, age_end: 49, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Damen', age_start: 21, age_end: 49, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Schüler A m', age_start: 13, age_end: 14, target_faces: [ '60cm' ] },
 { name: 'Recurve Schüler A w', age_start: 13, age_end: 14, target_faces: [ '60cm' ] },
 { name: 'Recurve Schüler B m', age_start: 11, age_end: 12, target_faces: [ '80cm' ] },
 { name: 'Recurve Schüler B w', age_start: 11, age_end: 12, target_faces: [ '80cm' ] },
 { name: 'Recurve Schüler C m', age_start: 1, age_end: 10, target_faces: [ '80cm (15m)' ] },
 { name: 'Recurve Schüler C w', age_start: 1, age_end: 10, target_faces: [ '80cm (15m)' ] },
 { name: 'Recurve Jugend m', age_start: 15, age_end: 17, target_faces: [ '40cm', '40cm Vegas Spot' ] },
 { name: 'Recurve Jugend w', age_start: 15, age_end: 17, target_faces: [ '40cm', '40cm Vegas Spot' ] },
 { name: 'Recurve Junioren m', age_start: 18, age_end: 20, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Junioren w', age_start: 18, age_end: 20, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Master m', age_start: 50, age_end: 65, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Master w', age_start: 50, age_end: 65, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Recurve Senioren w', age_start: 66, age_end: 120, target_faces: [ '40cm', '40cm Spot' ] },
 { name: 'Compound Herren', age_start: 21, age_end: 49, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Damen', age_start: 21, age_end: 49, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Schüler A m/w', age_start: 13, age_end: 14, target_faces: [ '60cm Spot (6-10 Ring)' ] },
 { name: 'Compound Schüler B m/w', age_start: 1, age_end: 12, target_faces: [ '60cm Spot (6-10 Ring)' ] },
 { name: 'Compound Jugend m/w', age_start: 15, age_end: 17, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Junioren m/w', age_start: 18, age_end: 20, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Master m', age_start: 50, age_end: 65, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Master w', age_start: 50, age_end: 120, target_faces: [ '40cm Spot' ] },
 { name: 'Compound Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm Spot' ] },
 { name: 'Blank Herren', age_start: 18, age_end: 120, target_faces: [ '40cm' ] },
 { name: 'Blank Damen', age_start: 18, age_end: 120, target_faces: [ '40cm' ] },
 { name: 'Blank Schüler A m', age_start: 1, age_end: 14, target_faces: [ '60cm' ] },
 { name: 'Blank Schüler A w', age_start: 1, age_end: 14, target_faces: [ '60cm' ] },
 { name: 'Blank Jugend m/w', age_start: 15, age_end: 17, target_faces: [ '40cm' ] },
 { name: 'Blank Master m', age_start: 50, age_end: 65, target_faces: [ '40cm Spot' ] },
 { name: 'Blank Master w', age_start: 50, age_end: 120, target_faces: [ '40cm Spot' ] },
 { name: 'Blank Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm Spot' ] }
]

tfs.each do |tf|
 TargetFace.create!(tf.merge({ tournament: vm }))
end

classes.each do |c|
 c[:target_faces] = c[:target_faces].map { |n| vm.target_faces.where({ name: n }) }.flatten
 TournamentClass.create!(c.merge({ tournament: vm }))
end
