require 'spec_helper'

describe DiscountCalculatorEC2 do
  before do
    @dc = DiscountCalculatorEC2.new
  end

  context "detect_instance_type" do
    it "detect_instance_type returns correct instance type by UsageType" do
      row = []
      row[15] = "APN1-EBSOptimized:r3.2xlarge"
      row[18] = "$0.05 for 1000 Mbps per r3.2xlarge instance-hour (or partial hour)"
      expect(@dc.detect_instance_type(row)).to eq("r3.2xlarge")
    end

    it "detect_instance_type returns correct instance type by ItemDescription" do
      row = []
      row[15] = "APN1-BoxUsage"
      row[18] = "$0.061 per On Demand Linux m1.small Instance Hour"
      expect(@dc.detect_instance_type(row)).to eq("m1.small")

      row = []
      row[15] = "APN1-BoxUsage"
      row[18] = "USD 0.0 per Linux/UNIX (Amazon VPC), m1.small instance-hour (or partial hour)"
      expect(@dc.detect_instance_type(row)).to eq("m1.small")
    end

    it "detect_instance_type raise error if unexpected row format" do
      row = []
      row[15] = "unexpected-format"
      row[18] = "unexpected-format"
      expect{ @dc.detect_instance_type(row) }.to raise_error(RuntimeError, "Unexpected row error. 'UsageType: unexpected-format' 'ItemDescription: unexpected-format'")
    end
  end

  context "detect_os" do
    it "detect_os returns correct os (RI) by ItemDescription" do
      row = []
      row[18] = "USD 0.0 per Linux/UNIX (Amazon VPC), m3.medium instance-hour (or partial hour)"
      expect(@dc.detect_os(row)).to eq("Linux")
    end

    it "detect_os returns correct os (On Demand) by ItemDescription" do
      row = []
      row[18] = "$0.798 per On Demand Linux r3.2xlarge Instance Hour"
      expect(@dc.detect_os(row)).to eq("Linux")
    end

    it "detect_os returns correct os (Dedicated) by ItemDescription" do
      row = []
      row[18] = "$0.141 per Dedicated Linux c3.large Instance Hour"
      expect(@dc.detect_os(row)).to eq("Linux")
    end

    it "detect_os returns correct os (Dedicated Usage) by ItemDescription" do
      row = []
      row[18] = "$0.146 per Dedicated Usage Linux c4.large Instance Hour"
      expect(@dc.detect_os(row)).to eq("Linux")
    end

    it "detect_os raise error if unexpected row format" do
      row = []
      row[18] = "unexpected-format"
      expect{ @dc.detect_os(row) }.to raise_error(RuntimeError, "Unexpected row error. 'ItemDescription: unexpected-format'")
    end
  end
end
