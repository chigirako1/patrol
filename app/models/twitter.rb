class Twitter < ApplicationRecord
    belongs_to :artists, :class_name => 'Artist'
end
