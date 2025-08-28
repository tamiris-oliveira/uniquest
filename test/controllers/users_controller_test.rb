require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @student = users(:student)
    @teacher = users(:teacher)
    @superadmin = users(:superadmin)
    @course = courses(:computer_science)
  end

  # Helper method to get auth headers
  def auth_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  test "should get index as superadmin" do
    get users_path, headers: auth_headers(@superadmin)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
  end

  test "should get index as teacher" do
    get users_path, headers: auth_headers(@teacher)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
  end

  test "should not get index without authentication" do
    get users_path
    assert_response :unauthorized
  end

  test "should create user with valid data" do
    assert_difference('User.count') do
      post users_path, 
           params: { 
             user: { 
               name: "Novo Usuário", 
               email: "novo@test.com", 
               password: "password123",
               role: 0,
               course_id: @course.id
             } 
           }
    end
    
    assert_response :created
    response_body = JSON.parse(response.body)
    assert_equal "Novo Usuário", response_body["name"]
    assert_equal "novo@test.com", response_body["email"]
  end

  test "should not create user with invalid data" do
    assert_no_difference('User.count') do
      post users_path, 
           params: { 
             user: { 
               name: "", 
               email: "invalid-email", 
               password: "123"
             } 
           }
    end
    
    assert_response :unprocessable_entity
  end

  test "should show profile" do
    get profile_path, headers: auth_headers(@student)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @student.name, response_body["name"]
    assert_equal @student.email, response_body["email"]
  end

  test "should update profile" do
    put profile_path, 
        params: { 
          user: { 
            name: "Nome Atualizado" 
          } 
        },
        headers: auth_headers(@student)
    
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal "Nome Atualizado", response_body["name"]
  end

  test "should not show profile without authentication" do
    get profile_path
    assert_response :unauthorized
  end

  test "should not update profile without authentication" do
    put profile_path, 
        params: { 
          user: { 
            name: "Nome Atualizado" 
          } 
        }
    
    assert_response :unauthorized
  end
end
