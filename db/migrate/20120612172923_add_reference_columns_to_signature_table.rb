class AddReferenceColumnsToSignatureTable < ActiveRecord::Migration
  def change
    add_column :signatures, :referer_id, :integer
    add_column :signatures, :reference_type, :string
  end
end
