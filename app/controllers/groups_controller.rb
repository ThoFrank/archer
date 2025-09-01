class GroupsController < ApplicationController
  before_action :set_tournament
  before_action :set_group, only: %i[ show edit update destroy ]

  def index
    @groups = Group.all
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.tournament = @tournament
      if @group.save
        redirect_to tournament_groups_path, notice: "Group was successfully created."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @group.update(group_params)
        redirect_to tournament_groups_path, notice: "Group was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @group.destroy
      redirect_to tournament_groups_path, notice: "Group was successfully deleted."
    end

  private
    def set_group
      @group = Group.find(params.expect(:id))
    end
    def group_params
      params.expect(group: [ :name ])
    end
end
