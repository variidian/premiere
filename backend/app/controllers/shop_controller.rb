class ShopController < ApplicationController
  before_action :require_user!

  ITEMS = [
    { id: 'sticker-pack', name: 'Premiere Sticker Pack', price: 3 },
    { id: 'keychain', name: 'Tiny Clapperboard Keychain', price: 8 },
    { id: 'poster', name: 'Premiere Poster', price: 12 },
    { id: 'mystery-box', name: 'Mystery Prize Box', price: 20 }
  ].freeze

  def purchase
    item = ITEMS.find { |shop_item| shop_item[:id] == params[:item_id] }
    return render json: { error: 'Unknown shop item' }, status: :not_found unless item
    return render json: { error: 'Not enough clapperboards' }, status: :unprocessable_entity if current_user.clapperboards.to_i < item[:price]

    current_user.update!(clapperboards: current_user.clapperboards.to_i - item[:price])
    render json: { item: item, clapperboards: current_user.clapperboards }
  end
end
