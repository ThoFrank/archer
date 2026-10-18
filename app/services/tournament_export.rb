class TournamentExport
  def initialize(tournament, include_participants: false)
    @tournament = tournament
    @include_participants = include_participants
  end

  def as_json
    data = {
      tournament: @tournament.as_json(only: %i[ name place date_start date_end season_start_date status enforce_club prevent_duplicate_registrations mail_text ])
        .merge("description" => @tournament.description.body.to_s),
      groups: @tournament.groups.order(:id).as_json(only: %i[ id name status ]),
      target_faces: @tournament.target_faces.order(:id).as_json(only: %i[ id name distance size ]),
      tournament_classes: @tournament.tournament_classes.includes(:target_faces).order(:id).as_json(
        only: %i[ id name age_start age_end price ianseo_name ianseo_division ],
        methods: :target_face_ids
      )
    }

    if @include_participants
      data[:participants] = @tournament.participants.includes(:registration).order(:id).as_json(
        only: %i[ id first_name last_name dob club group_id tournament_class_id target_face_id ],
        include: { registration: { only: %i[ id email comment ] } }
      )
    end

    data
  end
end
