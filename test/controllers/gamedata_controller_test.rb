require 'test_helper'

class GamedataControllerTest < ActionController::TestCase
  test "should get campaign" do
    get :campaign
    assert_response :success
  end

  test "should get combat_units" do
    get :combat_units
    assert_response :success
  end

  test "should get unit_levels" do
    get :unit_levels
    assert_response :success
  end

  test "should get defensive_building" do
    get :defensive_building
    assert_response :success
  end

  test "should get defensive_buildings_level" do
    get :defensive_buildings_level
    assert_response :success
  end

  test "should get resources_building_variables" do
    get :resources_building_variables
    assert_response :success
  end

  test "should get army_building" do
    get :army_building
    assert_response :success
  end

  test "should get other_buildings" do
    get :other_buildings
    assert_response :success
  end

  test "should get town_hall_level" do
    get :town_hall_level
    assert_response :success
  end

  test "should get decoration" do
    get :decoration
    assert_response :success
  end

  test "should get spell" do
    get :spell
    assert_response :success
  end

  test "should get spell_level" do
    get :spell_level
    assert_response :success
  end

  test "should get obstacles" do
    get :obstacles
    assert_response :success
  end

  test "should get effects" do
    get :effects
    assert_response :success
  end

  test "should get pretab" do
    get :pretab
    assert_response :success
  end

  test "should get trophy" do
    get :trophy
    assert_response :success
  end

  test "should get acheivements" do
    get :acheivements
    assert_response :success
  end

end
