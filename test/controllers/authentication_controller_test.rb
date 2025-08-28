require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @student = users(:student)
    @teacher = users(:teacher)
    @superadmin = users(:superadmin)
  end

  test "should login with valid credentials" do
    post login_path, params: {
      email: @student.email,
      password: "password123"
    }
    
    assert_response :success
    response_body = JSON.parse(response.body)
    assert response_body["token"].present?
    assert_equal @student.name, response_body["user"]["name"]
    assert_equal @student.email, response_body["user"]["email"]
  end

  test "should not login with invalid email" do
    post login_path, params: {
      email: "invalid@test.com",
      password: "password123"
    }
    
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid credentials", response_body["error"]
  end

  test "should not login with invalid password" do
    post login_path, params: {
      email: @student.email,
      password: "wrongpassword"
    }
    
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid credentials", response_body["error"]
  end

  test "should not login with missing parameters" do
    post login_path, params: {
      email: @student.email
    }
    
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid credentials", response_body["error"]
  end

  test "should login different user roles" do
    [@student, @teacher, @superadmin].each do |user|
      post login_path, params: {
        email: user.email,
        password: "password123"
      }
      
      assert_response :success
      response_body = JSON.parse(response.body)
      assert response_body["token"].present?
      assert_equal user.role, response_body["user"]["role"]
    end
  end
end
