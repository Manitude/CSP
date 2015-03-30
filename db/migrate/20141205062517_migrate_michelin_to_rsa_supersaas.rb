class MigrateMichelinToRsaSupersaas < ActiveRecord::Migration
  def self.up
  	Language["TMM-MCH-L"].update_attribute(:connection_type, "supersaas2")
  end

  def self.down
  	Language["TMM-MCH-L"].update_attribute(:connection_type, "supersaas1")
  end
end
