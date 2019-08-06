with open("hosts", 'w') as f:
    string = "[sitcon-camp:children]\nsitcon\nSITCON\n"
    
    string += "\n[sitcon]\n"
    with open("sitcon2019_ip_0.txt", 'r') as sitcon:
        string += sitcon.read()

    string += "\n[SITCON]\n"
    with open("SITCON2019_ip_1.txt", 'r') as SITCON:
        string += SITCON.read()
    
    string += "\n[sitcon:vars]\nansible_ssh_user=sitcon2019\n"
    string += "\n[SITCON:vars]\nansible_ssh_user=SITCON2019\n"
    string += "\n[all:vars]\nansible_connection=ssh\nansible_ssh_pass=SITCON2019"
    string += "\nansible_sudo_pass=SITCON2019"
    print(string, file=f)