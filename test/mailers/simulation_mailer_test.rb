require "test_helper"

class SimulationMailerTest < ActionMailer::TestCase
  test "new_simulation_assigned" do
    mail = SimulationMailer.new_simulation_assigned
    assert_equal "New simulation assigned", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
