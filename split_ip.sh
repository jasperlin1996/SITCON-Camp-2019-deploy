grep "SUCC" < ip.txt | awk '{print $1}' > sitcon2019_ip_0.txt
grep -B 2 "Per" < ip.txt | awk 'NR%4==1{print $1}' > SITCON2019_ip_1.txt

