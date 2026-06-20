class DevlogsController < ApplicationController
    before_action :require_user!, only: [:create]

    def index #fetch
        devlogs = Devlog.includes(:user, :project).order(created_at: :desc).limit(50)
        devlogs = devlogs.where(user: current_user) if params[:mine].present? && current_user
        devlogs = devlogs.where(project_id: params[:project_id]) if params[:project_id].present?

        render json: devlogs.map { |devlog| serialize_devlog(devlog) }
    end

    def create #save
        project = current_user.projects.find_by(id: params[:project_id]) if params[:project_id].present?

        devlog = current_user.devlogs.new(
            project: project,
            content: params[:content]
        )

        if devlog.save
            render json: serialize_devlog(devlog), status: :created
        else
            render json: { errors: devlog.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def serialize_devlog(devlog)
        {
            id: devlog.id,
            content: devlog.content,
            created_at: devlog.created_at,
            author: {
                display_name: devlog.user.display_name,
                avatar: devlog.user.avatar
            },
            project: devlog.project && {
                id: devlog.project.id,
                name: devlog.project.name,
                hackatime_project: devlog.project.hackatime_project
            }
        }
    end
end
