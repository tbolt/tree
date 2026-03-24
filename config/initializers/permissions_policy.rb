# Define an application-wide HTTP permissions policy.
# Privacy-focused: deny access to hardware features we don't need.

Rails.application.config.permissions_policy do |f|
  f.camera      :none
  f.gyroscope   :none
  f.microphone  :none
  f.usb         :none
  f.geolocation :none
  f.fullscreen  :self
  f.payment     :none
end
