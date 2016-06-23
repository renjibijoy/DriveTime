# DriveTime

### Running Locally on Mac

1) Open Terminal

2) Paste all of the following code at once:
```sh
cd ~/Desktop/
git clone https://github.com/renjibijoy/DriveTime.git
cd DriveTime
bundle install
rake db:create
rake db:migrate
(sleep 5; open http://localhost:3000) &
rails s
cd .
```

3) When finished using program, delete "DriveTime" folder from Desktop and close Terminal.