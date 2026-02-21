#!/usr/bin/env ruby
require_relative "../config/environment"

# Your code goes here
raise "Usage: scripts/vm_indoor_setup.rb tournament_id tournament_name" if ARGV.length != 2
vm = Tournament.find(ARGV[0].to_i)
raise "unexpected tournament name" unless vm.name == ARGV[1]

tfs = [
 { name: "70m - 122cm", distance: 70,	size: 122 },
 { name: "60m - 122cm", distance: 60,	size: 122 },
 { name: "50m - 122cm", distance: 50,	size: 122 },
 { name: "40m - 122cm", distance: 40,	size: 122 },
 { name: "25m - 80cm", distance: 25,	size: 80 },
 { name: "18m - 122cm", distance: 18,	size: 122 },
 { name: "50m - 80cm Spot", distance: 50,	size: 80 },
 { name: "40m - 80cm Spot", distance: 40,	size: 80 },
 { name: "30m - 122cm", distance: 30,	size: 122  }
]

classes = [
 { name: 'Recurve Herren', age_start: 21, age_end: 49, target_faces: [ '70m - 122cm' ], ianseo_division: 'R', ianseo_name: 'M' },
 { name: 'Recurve Damen', age_start: 21, age_end: 49, target_faces: [ '70m - 122cm' ], ianseo_division: 'R', ianseo_name: 'W' },
 { name: 'Recurve Schüler A m', age_start: 13, age_end: 14, target_faces: [ '40m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U15M' },
 { name: 'Recurve Schüler A w', age_start: 13, age_end: 14, target_faces: [ '40m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U15W' },
 { name: 'Recurve Schüler B m', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'R', ianseo_name: 'U13M' },
 { name: 'Recurve Schüler B w', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'R', ianseo_name: 'U13W' },
 { name: 'Recurve Schüler C m', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U11M' },
 { name: 'Recurve Schüler C w', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U11W' },
 { name: 'Recurve Schüler D m', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U9M' },
 { name: 'Recurve Schüler D w', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U9W' },
 { name: 'Recurve Jugend m', age_start: 15, age_end: 17, target_faces: [ '60m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U18M' },
 { name: 'Recurve Jugend w', age_start: 15, age_end: 17, target_faces: [ '60m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U18W' },
 { name: 'Recurve Junioren m', age_start: 18, age_end: 20, target_faces: [ '70m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U21M' },
 { name: 'Recurve Junioren w', age_start: 18, age_end: 20, target_faces: [ '70m - 122cm' ], ianseo_division: 'R', ianseo_name: 'U21W' },
 { name: 'Recurve Master m', age_start: 50, age_end: 65, target_faces: [ '60m - 122cm' ], ianseo_division: 'R', ianseo_name: 'UE49M' },
 { name: 'Recurve Master w', age_start: 50, age_end: 65, target_faces: [ '60m - 122cm' ], ianseo_division: 'R', ianseo_name: 'UE49W' },
 { name: 'Recurve Senioren m', age_start: 66, age_end: 120, target_faces: [ '50m - 122cm' ], ianseo_division: 'R', ianseo_name: 'UE65M' },
 { name: 'Recurve Senioren w', age_start: 66, age_end: 120, target_faces: [ '50m - 122cm' ], ianseo_division: 'R', ianseo_name: 'UE65W' },

 { name: 'Compound Herren', age_start: 21, age_end: 49, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'M' },
 { name: 'Compound Damen', age_start: 21, age_end: 49, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'W' },
 { name: 'Compound Schüler A m', age_start: 13, age_end: 14, target_faces: [ '40m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U15M' },
 { name: 'Compound Schüler A w', age_start: 13, age_end: 14, target_faces: [ '40m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U15W' },
 { name: 'Compound Schüler B m', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'C', ianseo_name: 'U13M' },
 { name: 'Compound Schüler B w', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'C', ianseo_name: 'U13W' },
 { name: 'Compound Schüler C m', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'C', ianseo_name: 'U11M' },
 { name: 'Compound Schüler C w', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'C', ianseo_name: 'U11W' },
 { name: 'Compound Schüler D m', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'C', ianseo_name: 'U9M' },
 { name: 'Compound Schüler D w', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'C', ianseo_name: 'U9W' },
 { name: 'Compound Jugend m', age_start: 15, age_end: 17, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U18M' },
 { name: 'Compound Jugend w', age_start: 15, age_end: 17, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U18W' },
 { name: 'Compound Junioren m', age_start: 18, age_end: 20, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U21M' },
 { name: 'Compound Junioren w', age_start: 18, age_end: 20, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'U21W' },
 { name: 'Compound Master m', age_start: 50, age_end: 65, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'UE49M' },
 { name: 'Compound Master w', age_start: 50, age_end: 65, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'UE49W' },
 { name: 'Compound Senioren m', age_start: 66, age_end: 120, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'UE65M' },
 { name: 'Compound Senioren w', age_start: 66, age_end: 120, target_faces: [ '50m - 80cm Spot' ], ianseo_division: 'C', ianseo_name: 'UE65W' },

 { name: 'Blank Herren', age_start: 21, age_end: 49, target_faces: [ '70m - 122cm' ], ianseo_division: 'B', ianseo_name: 'M' },
 { name: 'Blank Damen', age_start: 21, age_end: 49, target_faces: [ '70m - 122cm' ], ianseo_division: 'B', ianseo_name: 'W' },
 { name: 'Blank Schüler A m', age_start: 13, age_end: 14, target_faces: [ '40m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U15M' },
 { name: 'Blank Schüler A w', age_start: 13, age_end: 14, target_faces: [ '40m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U15W' },
 { name: 'Blank Schüler B m', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'B', ianseo_name: 'U13M' },
 { name: 'Blank Schüler B w', age_start: 11, age_end: 12, target_faces: [ '25m - 80cm' ], ianseo_division: 'B', ianseo_name: 'U13W' },
 { name: 'Blank Schüler C m', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U11M' },
 { name: 'Blank Schüler C w', age_start: 9, age_end: 10, target_faces: [ '18m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U11W' },
 { name: 'Blank Schüler D m', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U9M' },
 { name: 'Blank Schüler D w', age_start: 1, age_end: 8, target_faces: [ '18m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U9W' },
 { name: 'Blank Jugend m', age_start: 15, age_end: 17, target_faces: [ '60m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U18M' },
 { name: 'Blank Jugend w', age_start: 15, age_end: 17, target_faces: [ '60m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U18W' },
 { name: 'Blank Junioren m', age_start: 18, age_end: 20, target_faces: [ '70m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U21M' },
 { name: 'Blank Junioren w', age_start: 18, age_end: 20, target_faces: [ '70m - 122cm' ], ianseo_division: 'B', ianseo_name: 'U21W' },
 { name: 'Blank Master m', age_start: 50, age_end: 65, target_faces: [ '60m - 122cm' ], ianseo_division: 'B', ianseo_name: 'UE49M' },
 { name: 'Blank Master w', age_start: 50, age_end: 65, target_faces: [ '60m - 122cm' ], ianseo_division: 'B', ianseo_name: 'UE49W' },
 { name: 'Blank Senioren m', age_start: 66, age_end: 120, target_faces: [ '50m - 122cm' ], ianseo_division: 'B', ianseo_name: 'UE65M' },
 { name: 'Blank Senioren w', age_start: 66, age_end: 120, target_faces: [ '50m - 122cm' ], ianseo_division: 'B', ianseo_name: 'UE65W' }
]

tfs.each do |tf|
 TargetFace.create!(tf.merge({ tournament: vm }))
end

classes.each do |c|
 c[:target_faces] = c[:target_faces].map { |n| vm.target_faces.where({ name: n }) }.flatten
 TournamentClass.create!(c.merge({ tournament: vm }))
end
