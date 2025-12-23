class ParticipantsController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]
  before_action :set_tournament

  def index
    @participants = @tournament.participants.includes(:tournament_class, :target_face, :group)
    respond_to do |format|
      format.html
      format.csv do
        if authenticated?
          response.headers["Content-Type"] = "text/csv"
          if params[:query] == "ianseo"
            response.headers["Content-Disposition"] = "attachment; filename=#{@tournament.name}_participants.ianseo.csv"
            render template: "participants/index_ianseo"
          else
            response.headers["Content-Disposition"] = "attachment; filename=#{@tournament.name}_participants.csv"
            render template: "participants/index"
          end
        else
          request_authentication
        end
      end
    end
  end
end
