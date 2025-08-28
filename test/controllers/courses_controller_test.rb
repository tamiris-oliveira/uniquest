require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
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
    get courses_path, headers: auth_headers(@superadmin)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
    assert response_body.length > 0
  end

  test "should get index as teacher" do
    get courses_path, headers: auth_headers(@teacher)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
  end

  test "should get index as student" do
    get courses_path, headers: auth_headers(@student)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
  end

  test "should get index without authentication" do
    get courses_path
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.is_a?(Array)
    assert response_body.length > 0
  end

  test "should show course as superadmin" do
    get course_path(@course), headers: auth_headers(@superadmin)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @course.name, response_body["name"]
    assert_equal @course.code, response_body["code"]
  end

  test "should show course as teacher from same course" do
    get course_path(@course), headers: auth_headers(@teacher)
    assert_response :success
  end

  test "should create course as superadmin" do
    assert_difference('Course.count') do
      post courses_path, 
           params: { 
             course: { 
               name: "Novo Curso", 
               code: "NC", 
               description: "Descrição do novo curso" 
             } 
           },
           headers: auth_headers(@superadmin)
    end
    
    assert_response :created
    response_body = JSON.parse(response.body)
    assert_equal "Novo Curso", response_body["name"]
    assert_equal "NC", response_body["code"]
  end

  test "should not create course as teacher" do
    assert_no_difference('Course.count') do
      post courses_path, 
           params: { 
             course: { 
               name: "Novo Curso", 
               code: "NC", 
               description: "Descrição do novo curso" 
             } 
           },
           headers: auth_headers(@teacher)
    end
    
    assert_response :forbidden
  end

  test "should not create course as student" do
    assert_no_difference('Course.count') do
      post courses_path, 
           params: { 
             course: { 
               name: "Novo Curso", 
               code: "NC", 
               description: "Descrição do novo curso" 
             } 
           },
           headers: auth_headers(@student)
    end
    
    assert_response :forbidden
  end

  test "should update course as superadmin" do
    patch course_path(@course), 
          params: { 
            course: { 
              name: "Nome Atualizado" 
            } 
          },
          headers: auth_headers(@superadmin)
    
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal "Nome Atualizado", response_body["name"]
  end

  test "should not create course with invalid data" do
    assert_no_difference('Course.count') do
      post courses_path, 
           params: { 
             course: { 
               name: "", 
               code: "", 
               description: "Descrição" 
             } 
           },
           headers: auth_headers(@superadmin)
    end
    
    assert_response :unprocessable_entity
  end
end
