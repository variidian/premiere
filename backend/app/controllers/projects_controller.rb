class ProjectsController < ApplicationController
  before_action :require_user!, except: [:accepted]

  def index
    render json: current_user.projects.order(updated_at: :desc).map { |project| serialize_project(project) }
  end

  def accepted
    render json: Project.approved.includes(:user).map { |project| serialize_project(project) }
  end

  def create
    project = current_user.projects.new(project_params)

    if project.save
      render json: serialize_project(project), status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    project = current_user.projects.find(params[:id])

    if project.update(project_params)
      render json: serialize_project(project)
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def project_params
    allowed = params.permit(:name, :description, :hackatime_project, :hackatime_hours, :repository_url, :demo_url, :image_url, :status)
    allowed.delete(:status) unless %w[not_yet_shipped pending_approval].include?(allowed[:status])
    allowed[:submitted_at] = Time.current if allowed[:status] == 'pending_approval'
    allowed
  end

  def serialize_project(project)
    {
      id: project.id,
      name: project.name,
      description: project.description,
      hackatime_project: project.hackatime_project,
      hackatime_hours: project.hackatime_hours,
      repository_url: project.repository_url,
      demo_url: project.demo_url,
      image_url: project.image_url,
      status: project.status,
      submitted_at: project.submitted_at,
      accepted_at: project.accepted_at,
      updated_at: project.updated_at,
      author: {
        display_name: project.user.display_name,
        avatar: project.user.avatar
      }
    }
  end
end
