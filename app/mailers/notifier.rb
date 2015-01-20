class Notifier < ActionMailer::Base
  default :from => "customerservice@lum.ba"
  def welcome(recipient)
    @account = recipient
    mail(:to => recipient, :subject => "Lumba Customer Service")
  end
end
