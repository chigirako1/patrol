class PxvArtwork < ApplicationRecord
    validates :artwork_id, uniqueness: true

    module StateEnum
        UNACCESSIBLE_URL = "URLアクセス不可"
        UNKNOWN = "不明"
        SAVED = "保存済み"
        TO_BE_REMOVED = "削除予定"
        REMOVED = "削除済み"
        REMOVED_UNNECESSARY = "削除済み(不要)"
        REMOVED_DUP = "削除済み(重複)"
    end

    def self.state_list
        list = [
            StateEnum::UNKNOWN,
            StateEnum::SAVED,
            StateEnum::TO_BE_REMOVED,
            StateEnum::REMOVED,
            StateEnum::REMOVED_UNNECESSARY,
            StateEnum::REMOVED_DUP,
            StateEnum::UNACCESSIBLE_URL,
        ]
        list.map {|x| [x, x]}
    end

    def find_artist()
        if user_id
            pxv_artist = Artist.find_by(pxvid: user_id)
            pxv_artist
        else
            nil
        end
    end

    def info_txt
        %!#{state}/#{I18n.l(release_date, format: :date) if release_date}/user_id:#{user_id}/「#{title}」(#{number_of_pic}枚?)!
    end
end
