require 'csv'
require 'tmpdir'
require 'fileutils'

module TestHelpers

  def test_dir
    Dir.tmpdir + "/harness/"
  end

  def create_fdata_files
    scenario = [
      {:sector => "Sector1", :name => "Product1", :data => [["Date","price"], ['2014-3-7', 300], ['2014-3-6', 280], ['2014-3-2', 270], ['2014-3-1', 290]]},
      {:sector => "Sector1", :name => "Product2", :data => [["Date","price"], ['2014-3-7', 400], ['2014-3-6', 380], ['2014-3-2', 370], ['2014-3-1', 390]]},
      {:sector => "Sector2", :name => "Product3", :data => [["Date","price"], ['2014-3-7', 500], ['2014-3-6', 480], ['2014-3-2', 470], ['2014-3-1', 490]]},
      {:sector => "Sector2", :name => "Product4", :data => [["Date","price"]]},
    ]
    FileUtils.mkdir_p(test_dir)
    scenario.each do |scene|
      FileUtils.mkdir_p(test_dir + scene[:sector])
      CSV.open(test_dir + scene[:sector] + "/" + scene[:name] + ".csv", "wb") do |csv|
        scene[:data].each { |d| csv << d }
      end
    end

  end

  def destroy_fdata_files
    # test_dir = Dir.tmpdir + "/harness/"
    FileUtils.rm_rf(test_dir)
  end

end
