class UserMailer < ActionMailer::Base

  def test_task(user, url, description)
    setup_email(user)
    subject title = "Bitte testen Sie #{description}."
    
    body :url => url,
         :user => user,
         :title => title
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "noreply@example.com"
      @sent_on     = Time.now
      @body[:user] = user
    end
end
