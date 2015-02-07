require 'rails_helper'
require 'csv'
require 'tmpdir'
require 'fileutils'
# Specs in this file have access to a helper object that includes
# the FDataUtilsHelper. For example:
#
# describe FDataUtilsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe FDataUtilsHelper, type: :helper do
  describe "data utilities -> filling blank data" do

    it "responds to a method named fill_blank_fdata" do
      expect(FDataUtilsHelper.respond_to?(:fill_blank_fdata)).to be true
    end

    it "fills up missing data for single anomaly of one day in between dates" do
      input           = [['2014-3-1', 290], ['2014-3-2', 270], ['2014-3-4', 280], ['2014-3-5', 300]]
      expected_output = [290, 270, 270, 280, 300]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to eql(expected_output)
    end

    it "fills up missing data for single anomaly of multiple days in between dates" do
      input           = [['2014-3-1', 290], ['2014-3-2', 270], ['2014-3-6', 280], ['2014-3-7', 300]]
      expected_output = [290, 270, 270, 270, 270, 280, 300]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to eql(expected_output)
    end

    it "fills up missing data for multiple anomalies of multiple days in between dates" do
      input           = [['2014-3-1', 290], ['2014-3-2', 270], ['2014-3-6', 280], ['2014-3-7', 300],
                         ['2014-3-8', 295], ['2014-3-10', 297], ['2014-3-11', 299]]
      expected_output = [290, 270, 270, 270, 270, 280, 300, 295, 295, 297, 299]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to eql(expected_output)
    end

    it "fills up missing data right after starting date itself" do
      input           = [['2014-3-1', 290], ['2014-3-6', 280], ['2014-3-7', 300]]
      expected_output = [290, 290, 290, 290, 290, 280, 300]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to eql(expected_output)
    end

    it "fills up missing data right before ending date itself" do
      input           = [['2014-3-1', 290], ['2014-3-2', 280], ['2014-3-7', 300]]
      expected_output = [290, 280, 280, 280, 280, 280, 300]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to eql(expected_output)
    end

    it "does not match expectation for dates in descending order" do
      input           = [['2014-3-1', 290], ['2014-3-2', 280], ['2014-3-7', 300]].reverse
      expected_output = [290, 280, 280, 280, 280, 280, 300]

      expect(FDataUtilsHelper.fill_blank_fdata(input)).to_not eql(expected_output)
    end
  end
  describe "data utilities -> data from file reading" do
    before :each do

      scenario = [
        {:sector => "Sector1", :name => "Product1", :data => [["Date","price"], ['2014-3-7', 300], ['2014-3-6', 280], ['2014-3-2', 270], ['2014-3-1', 290]]},
        {:sector => "Sector1", :name => "Product2", :data => [["Date","price"], ['2014-3-7', 400], ['2014-3-6', 380], ['2014-3-2', 370], ['2014-3-1', 390]]},
        {:sector => "Sector2", :name => "Product3", :data => [["Date","price"], ['2014-3-7', 500], ['2014-3-6', 480], ['2014-3-2', 470], ['2014-3-1', 490]]},
        {:sector => "Sector2", :name => "Product4", :data => [["Date","price"]]},
      ]
      test_dir = Dir.tmpdir + "/harness/"
      FileUtils.mkdir_p(test_dir)
      scenario.each do |scene|
        FileUtils.mkdir_p(test_dir + scene[:sector])
        CSV.open(test_dir + scene[:sector] + "/" + scene[:name] + ".csv", "wb") do |csv|
          scene[:data].each { |d| csv << d }
        end
      end

    end
    after :each do
      test_dir = Dir.tmpdir + "/harness/"
      FileUtils.rm_rf(test_dir)
    end

    it "correctly reads all sectors" do
      expected_sectors = ['Sector1', 'Sector2']
      out = FDataUtilsHelper::FDataFileReader.read_data_from_directory(Dir.tmpdir + "/harness/").keys

      expect(out).to eql(expected_sectors)
    end

    it "correctly reads all product data" do
      expected_sector1 = {
        "Product1" => [['2014-3-7', 300.0], ['2014-3-6', 280.0], ['2014-3-2', 270.0], ['2014-3-1', 290.0]].reverse,
        "Product2" => [['2014-3-7', 400.0], ['2014-3-6', 380.0], ['2014-3-2', 370.0], ['2014-3-1', 390.0]].reverse,
      }
      expected_sector2 = {
        "Product3" => [['2014-3-7', 500.0], ['2014-3-6', 480.0], ['2014-3-2', 470.0], ['2014-3-1', 490.0]].reverse,
      }

      out = FDataUtilsHelper::FDataFileReader.read_data_from_directory(Dir.tmpdir + "/harness/")

      expect(out["Sector1"]).to eql(expected_sector1)
      expect(out["Sector2"]).to eql(expected_sector2)
    end

    it "ignores product files with only one entry" do
      out = FDataUtilsHelper::FDataFileReader.read_data_from_directory(Dir.tmpdir + "/harness/")

      expect(out["Sector2"].has_key? "Product4").to be false
    end

    it "clears out the directory from which it reads data" do
      FDataUtilsHelper::FDataFileReader.read_data_from_directory(Dir.tmpdir + "/harness/")

      expect(Dir.exist?(Dir.tmpdir + "/harness/")).to be false
    end

  end
end
