class ReferralsController < ApplicationController
  before_action :require_user!
  before_action :require_admin!

  def index
    referrals = User.where.not(referred_by: [nil, '']).where.not(referral_paid: true).order(created_at: :desc)
    render json: referrals.map { |user| serialize_referral(user) }
  end

  def approve
    referred_user = User.find(params[:id])
    return render json: { error: 'Referral already awarded' }, status: :unprocessable_entity if referred_user.referral_paid
    return render json: { error: 'No referral code recorded' }, status: :unprocessable_entity if referred_user.referred_by.blank?
    return render json: { error: 'Cannot award self-referral' }, status: :unprocessable_entity if referred_user.referred_by == referred_user.slack_id

    referrer = User.find_by(slack_id: referred_user.referred_by) || User.find_by(token: referred_user.referred_by)
    return render json: { error: 'Referrer not found' }, status: :not_found unless referrer

    referrer.update!(
      referrals: referrer.referrals.to_i + 1,
      clapperboards: referrer.clapperboards.to_i + 1
    )
    referred_user.update!(referral_paid: true)

    render json: {
      referral: serialize_referral(referred_user),
      referrer: {
        id: referrer.id,
        display_name: referrer.display_name,
        slack_id: referrer.slack_id,
        referrals: referrer.referrals,
        clapperboards: referrer.clapperboards
      }
    }
  end

  private

  def require_admin!
    render json: { error: 'Admin only' }, status: :forbidden unless current_user&.admin?
  end

  def serialize_referral(user)
    referrer = User.find_by(slack_id: user.referred_by) || User.find_by(token: user.referred_by)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      slack_id: user.slack_id,
      display_name: user.display_name,
      avatar: user.avatar,
      referred_by: user.referred_by,
      referral_paid: user.referral_paid,
      created_at: user.created_at,
      referrer: referrer && {
        id: referrer.id,
        display_name: referrer.display_name,
        slack_id: referrer.slack_id,
        referrals: referrer.referrals,
        clapperboards: referrer.clapperboards
      }
    }
  end
end
