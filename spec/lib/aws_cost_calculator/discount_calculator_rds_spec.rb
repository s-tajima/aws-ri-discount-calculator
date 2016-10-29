require 'spec_helper'

describe DiscountCalculatorRDS do
  before do
    @dc = DiscountCalculatorRDS.new
  end

  context "detect_instance_type" do
    it "detect_instance_type returns correct instance type by UsageType" do
      row = []
      row[15] = "APN1-Multi-AZUsage:db.t2.small"
      expect(@dc.detect_instance_type(row)).to eq("db.t2.small")
    end

    it "detect_instance_type raise error if unexpected row format" do
      row = []
      row[15] = "unexpected-format"
      expect{ @dc.detect_instance_type(row) }.to raise_error(RuntimeError, "Unexpected row error. 'UsageType: unexpected-format'")
    end
  end

  context "detect_database_engine" do
    it "detect_database_engine returns correct database engine by ItemDescription" do
      row = []
      row[18] = "$0.112 per RDS db.t2.small Multi-AZ instance hour (or partial hour) running PostgreSQL"
      expect(@dc.detect_database_engine(row)).to eq("PostgreSQL")
    end

    it "detect_database_engine raise error if unexpected row format" do
      row = []
      row[18] = "unexpected-format"
      expect{ @dc.detect_database_engine(row) }.to raise_error(RuntimeError, "Unexpected row error. 'ItemDescription: unexpected-format'")
    end
  end

  context "detect_database_edition" do
    it "detect_database_edition returns correct database edition by ItemDescription" do
      row = []
      row[18] = "$0.044 per RDS db.t2.micro instance hour (or partial hour) running Oracle SE2 (LI)"
      expect(@dc.detect_database_edition(row)).to eq("Standard Two")
    end

    it "detect_database_edition returns empty value by ItemDescription" do
      row = []
      row[18] = "$0.112 per RDS db.t2.small Multi-AZ instance hour (or partial hour) running PostgreSQL"
      expect(@dc.detect_database_edition(row)).to eq("")
    end
  end

  context "detect_deployment_option" do
    it "detect_deployment_option returns correct deployment option (Multi-AZ) by UsageType" do
      row = []
      row[15] = "APN1-Multi-AZUsage:db.t2.small"
      row[18] = "$0.112 per RDS db.t2.small Multi-AZ instance hour (or partial hour) running PostgreSQL"
      expect(@dc.detect_deployment_option(row)).to eq("Multi-AZ")
    end

    it "detect_deployment_option returns correct deployment option (Single-AZ) by UsageType" do
      row = []
      row[15] = "APN1-InstanceUsage:db.t2.small"
      row[18] = "$0.052 per RDS db.t2.small instance hour (or partial hour) running MySQL"
      expect(@dc.detect_deployment_option(row)).to eq("Single-AZ")
    end
  end

  context "detect_license_model" do
    it "detect_license_model returns correct license model (MySQL) by ItemDescription" do
      row = []
      row[18] = "$4.54 per RDS db.r3.4xlarge Multi-AZ instance hour (or partial hour) running MySQL"
      db_engine = "MySQL"
      expect(@dc.detect_license_model(row, db_engine)).to eq("No license required")
    end

    it "detect_license_model returns correct license model (Oracle) by ItemDescription" do
      row = []
      row[18] = "$0.041 per RDS db.t2.micro instance hour (or partial hour) running Oracle SE1 (LI)"
      db_engine = "Oracle"
      expect(@dc.detect_license_model(row, db_engine)).to eq("License included")
    end

    it "detect_license_model raise error if unexpected row format" do
      row = []
      row[18] = "unexpected-format"
      db_engine = "Oracle"
      expect{ @dc.detect_license_model(row, db_engine) }.to raise_error(RuntimeError, "Unexpected row error. 'ItemDescription: unexpected-format'")
    end
  end
end
