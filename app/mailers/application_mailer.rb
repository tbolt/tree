class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@tree.fly.dev"
  layout "mailer"
end
