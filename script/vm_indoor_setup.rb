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
 { name: 'Recurve Herren', age_start: 21, age_end: 49, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RUE20M', ianseo_division: 'R' },
 { name: 'Recurve Damen', age_start: 21, age_end: 49, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RUE20W', ianseo_division: 'R' },
 { name: 'Recurve Schüler A m', age_start: 13, age_end: 14, target_faces: [ '60cm' ], ianseo_name: 'RU15M', ianseo_division: 'R' },
 { name: 'Recurve Schüler A w', age_start: 13, age_end: 14, target_faces: [ '60cm' ], ianseo_name: 'RU15W', ianseo_division: 'R' },
 { name: 'Recurve Schüler B m', age_start: 11, age_end: 12, target_faces: [ '80cm' ], ianseo_name: 'RU13M', ianseo_division: 'R' },
 { name: 'Recurve Schüler B w', age_start: 11, age_end: 12, target_faces: [ '80cm' ], ianseo_name: 'RU13W', ianseo_division: 'R' },
 { name: 'Recurve Schüler C m', age_start: 1, age_end: 10, target_faces: [ '80cm (15m)' ], ianseo_name: 'RU11M', ianseo_division: 'R' },
 { name: 'Recurve Schüler C w', age_start: 1, age_end: 10, target_faces: [ '80cm (15m)' ], ianseo_name: 'RU11W', ianseo_division: 'R' },
 { name: 'Recurve Jugend m', age_start: 15, age_end: 17, target_faces: [ '40cm', '40cm Vegas Spot' ], ianseo_name: 'RU18M', ianseo_division: 'R' },
 { name: 'Recurve Jugend w', age_start: 15, age_end: 17, target_faces: [ '40cm', '40cm Vegas Spot' ], ianseo_name: 'RU18M', ianseo_division: 'R' },
 { name: 'Recurve Junioren m', age_start: 18, age_end: 20, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RU21M', ianseo_division: 'R' },
 { name: 'Recurve Junioren w', age_start: 18, age_end: 20, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RU21W', ianseo_division: 'R' },
 { name: 'Recurve Master m', age_start: 50, age_end: 65, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RUE49M', ianseo_division: 'R' },
 { name: 'Recurve Master w', age_start: 50, age_end: 65, target_faces: [ '40cm', '40cm Spot' ], ianseo_name: 'RUE49M', ianseo_division: 'R' },
 { name: 'Recurve Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm', '40cm Vegas Spot' ], ianseo_name: 'RUE65M', ianseo_division: 'R' },
 { name: 'Recurve Senioren w', age_start: 66, age_end: 120, target_faces: [ '40cm', '40cm Vegas Spot' ], ianseo_name: 'RUE65W', ianseo_division: 'R' },
 { name: 'Compound Herren', age_start: 21, age_end: 49, target_faces: [ '40cm Spot' ], ianseo_name: 'CUE20M', ianseo_division: 'C' },
 { name: 'Compound Damen', age_start: 21, age_end: 49, target_faces: [ '40cm Spot' ], ianseo_name: 'CUE20W', ianseo_division: 'C' },
 { name: 'Compound Schüler A m/w', age_start: 13, age_end: 14, target_faces: [ '60cm Spot (6-10 Ring)' ], ianseo_name: 'CU15M', ianseo_division: 'C' },
 { name: 'Compound Schüler B m/w', age_start: 1, age_end: 12, target_faces: [ '60cm Spot (6-10 Ring)' ], ianseo_name: 'CU15W', ianseo_division: 'C' },
 { name: 'Compound Jugend m/w', age_start: 15, age_end: 17, target_faces: [ '40cm Spot' ], ianseo_name: 'CU18M', ianseo_division: 'C' },
 { name: 'Compound Junioren m/w', age_start: 18, age_end: 20, target_faces: [ '40cm Spot' ], ianseo_name: 'CU18W', ianseo_division: 'C' },
 { name: 'Compound Master m', age_start: 50, age_end: 65, target_faces: [ '40cm Spot' ], ianseo_name: 'CUE49M', ianseo_division: 'C' },
 { name: 'Compound Master w', age_start: 50, age_end: 120, target_faces: [ '40cm Spot' ], ianseo_name: 'CUE49W', ianseo_division: 'C' },
 { name: 'Compound Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm Spot' ], ianseo_name: 'CUE65M', ianseo_division: 'C' },
 { name: 'Blank Herren', age_start: 18, age_end: 49, target_faces: [ '40cm' ], ianseo_name: 'BUE17M', ianseo_division: 'B' },
 { name: 'Blank Damen', age_start: 18, age_end: 49, target_faces: [ '40cm' ], ianseo_name: 'BUE17W', ianseo_division: 'B' },
 { name: 'Blank Schüler A m', age_start: 1, age_end: 14, target_faces: [ '60cm' ], ianseo_name: 'BU15M', ianseo_division: 'B' },
 { name: 'Blank Schüler A w', age_start: 1, age_end: 14, target_faces: [ '60cm' ], ianseo_name: 'BU15W', ianseo_division: 'B' },
 { name: 'Blank Jugend m/w', age_start: 15, age_end: 17, target_faces: [ '40cm' ], ianseo_name: 'BU18', ianseo_division: 'B' },
 { name: 'Blank Master m', age_start: 50, age_end: 65, target_faces: [ '40cm Spot' ], ianseo_name: 'BUE49M', ianseo_division: 'B' },
 { name: 'Blank Master w', age_start: 50, age_end: 120, target_faces: [ '40cm Spot' ], ianseo_name: 'BUE49W', ianseo_division: 'B' },
 { name: 'Blank Senioren m', age_start: 66, age_end: 120, target_faces: [ '40cm Spot' ], ianseo_name: 'BUE65M', ianseo_division: 'B' },
 { name: 'Offene Klasse', age_start: 1, age_end: 120, target_faces: [ '60cm' ], ianseo_name: 'O', ianseo_division: 'O' }
]

tfs.each do |tf|
 TargetFace.create!(tf.merge({ tournament: vm }))
end

classes.each do |c|
 c[:target_faces] = c[:target_faces].map { |n| vm.target_faces.where({ name: n }) }.flatten
 TournamentClass.create!(c.merge({ tournament: vm }))
end
