# Stop COVID Tunisia
com.aaronhaddad.stopcovidtunisia

# What is it?
I created this app in the hope of helping to prevent COVID in my country Tunisia. Despite learning a lot of things, this project was unfortunately a failure due to some system restricitions. Read more!

# How it does it?
Stop COVID uses Bluetooth to scan for surrounding devices's Bluetooth address, it stores these addresses in a local database. On the other hand if someone is COVID positive, his Bluetooth address will be uploaded to a remote database thus allowing the app to notify the users of a risk of a contamination by a simple db fetch.

# Why it failed?
The failure is due to mainly two system restrictions. I have focused on the Android side a lot when developing the app:
  1. It is impossible for non system apps to get the device's Bluetooth address using the getAddress() method
  2. When launching a scan I noticed that not all devices were shown and that the oens shown did not show their correct Bluetooth address. I believe this is due to BLE (Bluetooth   low energy) and security concerns.
 
# Functionalities:
  1. Login / Registration (Firebase auth)
  2. Realtime databse to store infected Bluetooth addresses (Firebase RealtimeDb)
  3. Local SQL db (using SQFlite Flutter plugin) to store user's name along other DATA that helps the app work perfectly
  4. Local SQL db (using SQFlite Flutter plugin) to store the Bluetooth addresses of the surrounding devices
  5. The local databse containing the Bluetooth addresses of the surrounding devices is automatically deleted after 15 days or when the person is not positive anymore
  6. A scan reminder notification (The user can choose whether to enable or disable this notification)
 
# Can I contribute?
If you know how we can this app work please feel free and bring this app to your country, it will help save countless lives! ❤️

# I'm sure we can this work!
  

  
