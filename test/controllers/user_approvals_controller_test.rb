require "test_helper"

class UserApprovalsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_approvals_index_url
    assert_response :success
  end

  test "should get approve" do
    get user_approvals_approve_url
    assert_response :success
  end

  test "should get reject" do
    get user_approvals_reject_url
    assert_response :success
  end

  test "should get request_teacher_role" do
    get user_approvals_request_teacher_role_url
    assert_response :success
  end
end
