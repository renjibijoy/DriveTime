# DriveTime

### Running Locally on Mac/Linux

1) Open Terminal

2) Paste all of the following code at once:
```sh
git clone https://github.com/renjibijoy/DriveTime.git
cd DriveTime
bundle install
rake db:create
rake db:migrate
( sleep 5; open http://localhost:3000) &
rails s
```