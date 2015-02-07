require 'rails_helper'

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
  describe "data reading utilities -> filling blank data" do

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
end
