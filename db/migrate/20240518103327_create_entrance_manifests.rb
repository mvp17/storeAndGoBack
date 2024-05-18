class CreateEntranceManifests < ActiveRecord::Migration[7.1]
  def change
    create_table :entrance_manifests do |t|
      t.string :reference
      t.string :entranceDate
      t.string :origin

      t.timestamps
    end
  end
end
