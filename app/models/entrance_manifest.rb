class EntranceManifest < ApplicationRecord    
    key :id, :timeuuid, auto: true
    column :ref, :text
    column :date, :text
    column :origin, :text
    
    timestamps
end
