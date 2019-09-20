
#!/bin/bash

pad=/home/
bestand=file.yaml

cat <<EOT>> $pad$bestand
lu_defaults::apache_vhosts:
lu_defaults::sshd_allowgroups: ['apache', 'apache-admins', 'admin']
lu_profile_lamp_ng::webmasters_group: 'g-ug-admins'
lu_profile_lamp_ng::use_phpmyadmin: true
lu_defaults::ssh::sshd_config_match:
  'Group G-UG-UB-ADMINS':
    - 'AllowTcpForwarding no'
    - 'ChrootDirectory /data'
    - 'X11Forwarding no'
    - 'ForceCommand internal-sftp'
lu_defaults::ad_sudo_groups: ['g-ug-srv-admins', 'g-ug-ias-as-admins', 'g-ug-migration-admins']
lookup_options:
  sudo::configs:
    merge:
     strategy: deep
     merge_hash_arrays: true
     sudo::configs:
  'ad-luci-migration-admins':
    'content': "%g-ug-migration-admins ALL=(ALL) ALL"
    'priority': 10
  'ad-luci-ias-as-admins':
    'content': "%g-ug-ias-as-admins ALL=(ALL) ALL"
    'priority': 10
  # migrated websites
lu_defaults::apache_vhosts_https:
EOT

for file in *.conf; do

   if [[ $file =~ .*ssl.* ]]
    then
             servername=$(cat $file | egrep 'ServerName'  | tr -s " " | sed 's/^[ ]//g' | cut -d ' ' -f 2 | sed 's/www.//g' | sed 's/:443//g' | sort)
             echo -e "  '$servername-ssl':"  >> $pad$bestand
             serveralias=$(cat $file |egrep 'ServerAlias' | tr -s " " | sed 's/^[ ]//g' | cut -d ' ' -f2- | sort -u | uniq)
           if [[ $serveralias ]]; then

                saclean=$(echo $serveralias | awk '{gsub(/^|$/,"\x027");gsub(/ /,"\x027,\x027")}7')
                echo -e "    serveraliases: [$saclean]" >> $pad$bestand
           fi
            echo -e "    override: 'All'\n" >> $pad$bestand
    else


    servername=$(cat $file | egrep 'ServerName'  | tr -s " " | sed 's/^[ ]//g' | cut -d ' ' -f 2 | sed 's/www.//g' | sed 's/:443//g' | sort)
    echo -e "  '$servername':"  >> $pad$bestand
    serveralias=$(cat $file |egrep 'ServerAlias' | tr -s " " | sed 's/^[ ]//g' | cut -d ' ' -f2- | sort -u | uniq)
        if [[ $serveralias ]]; then

            saclean=$(echo $serveralias | awk '{gsub(/^|$/,"\x027");gsub(/ /,"\x027,\x027")}7')
            echo -e "    serveraliases: [$saclean]" >> $pad$bestand

        fi
    echo -e "    override: 'All'\n" >> $pad$bestand

   fi
done

echo "De YAML config is aangemaakt in $pad$bestand"








