class AdminProjectsController < ApplicationController
  before_action :require_user!
  before_action :require_admin!

  def index
    projects = Project.includes(:user).order(updated_at: :desc)
    projects = projects.where(status: params[:status]) if params[:status].present?
    render json: projects.map { |project| serialize_project(project) }
  end

  def update
    project = Project.find(params[:id])
    status = params[:status]
    return render json: { error: 'Invalid status' }, status: :unprocessable_entity unless %w[approved rejected pending_approval not_yet_shipped].include?(status)

    attrs = { status: status }
    attrs[:accepted_at] = Time.current if status == 'approved'
    project.update!(attrs)
    render json: serialize_project(project)
  end

  private

  def require_admin!
    render json: { error: 'Admin only' }, status: :forbidden unless current_user&.admin?
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
        slack_id: project.user.slack_id,
        avatar: project.user.avatar
      }
    }
  end
end
