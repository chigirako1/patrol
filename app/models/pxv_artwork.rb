class PxvArtwork < ApplicationRecord
  validates :artwork_id, uniqueness: true

  module StateEnum
    UNKNOWN = "不明"
    SAVED = "保存済み"
    TO_BE_REMOVED = "削除予定"
    REMOVED = "削除"
  end

  def self.state_list
    list = [
      StateEnum::UNKNOWN,
      StateEnum::SAVED,
      StateEnum::TO_BE_REMOVED,
      StateEnum::REMOVED,
    ]
    list.map {|x| [x, x]}
end
end
