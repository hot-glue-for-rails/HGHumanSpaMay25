class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_enum "treatment_types",  %w[manicure pedicure massage haircut]

    create_table :appointments do |t|
      t.time :when_at
      t.integer :user_id
      t.enum :treatment, enum_type: "treatment_types"

      t.timestamps
    end
  end
end
