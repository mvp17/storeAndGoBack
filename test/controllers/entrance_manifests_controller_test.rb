require "test_helper"

class EntranceManifestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get entrance_manifests_index_url
    assert_response :success
  end

  test "should get show" do
    get entrance_manifests_show_url
    assert_response :success
  end

  test "should get create" do
    get entrance_manifests_create_url
    assert_response :success
  end

  test "should get update" do
    get entrance_manifests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get entrance_manifests_destroy_url
    assert_response :success
  end
end
