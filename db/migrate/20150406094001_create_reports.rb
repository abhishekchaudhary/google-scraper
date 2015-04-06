class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :user, index: true
      t.string :keyword
      t.string :top_adwords_url, array: true , default: '{}'
      t.string :right_adwords_url, array: true, default: '{}'
      t.string :non_adwords_url, array: true, default: '{}'
      t.string :total_results
      t.text :page_cache

      t.timestamps
    end
  end
end
