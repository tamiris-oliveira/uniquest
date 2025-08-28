require "test_helper"

class CorrectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get corrections_index_url
    assert_response :success
  end

  test "should get create" do
    get corrections_create_url
    assert_response :success
  end

  test "should get show" do
    get corrections_show_url
    assert_response :success
  end

  test "should get update" do
    get corrections_update_url
    assert_response :success
  end

  test "should get destroy" do
    get corrections_destroy_url
    assert_response :success
  end
end
