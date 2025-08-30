require "test_helper"

class CorrectionMailerTest < ActionMailer::TestCase
  test "correction_completed" do
    mail = CorrectionMailer.correction_completed
    assert_equal "Correction completed", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
