#!/usr/bin/env bash

domain=$1
output=$2

get_dns_records () {
  echo ""
  echo "DNS enumeration for $domain"
  echo "-------------------------------------------------------------------------------"
  date
  echo "---"
  echo ""
  echo "host results"
  echo "------------"
  host $domain
  echo ""
  echo "whois results"
  echo "-------------"
  whois $domain
  echo ""
  echo "-------------------------------------------------------------------------------"
  echo "" 
  echo "dig results"
  echo "----------------------------------------"
  echo ""
  echo "Name servers"
  echo "------------"
  dig $domain -t ns +short
  echo ""
  echo "A records"
  echo "---------"
  dig $domain -t a +short
  echo ""
  echo "AAAA records"
  echo "------------"
  dig $domain -t aaaa +short
  echo ""
  echo "MX records"
  echo "----------"
  dig $domain -t mx +short
  echo ""
  echo "SOA records"
  echo "-----------"
  dig $domain -t soa +short
  echo "" 
  echo "CNAME records"
  echo "-------------"
  dig $domain -t cname +short
  echo ""
  echo "PTR records"
  echo "-----------" 
  dig $domain -t ptr +short
  echo ""
  echo "TXT records"
  echo "-------------------"
  dig $domain -t txt +short
  echo ""
  echo "Searching for common SRV records"
  echo "--------------------------------"
  echo ""
  echo "Session Initial Protocol (SIP)"
  echo "------------------------------"
  dig _sipfederationtls._tcp.$domain -t srv +short
  dig _sip._tcp.$domain -t srv +short
  dig _sip._tls.$domain -t srv +short
  dig _sip._udp.$domain -t srv +short
  echo ""
  echo "Cisco Expressway"
  echo "----------------"
  dig _h323cs._tcp.$domain -t srv +short
  dig _h323ls._udp.$domain -t srv +short
  dig _h323rs._tcp.$domain -t srv +short
  dig _sips._tcp.$domain -t srv +short
  dig _turn._udp.$domain -t srv +short
  dig _collab-edge._tls.$domain -t srv +short
  dig _cisco-uds._tcp.$domain -t srv +short
  dig _cuplogin._tcp.$domain -t srv +short
  echo ""
  echo "XMPP"
  echo "----"
  dig _xmpp-client._tcp.$domain -t srv +short
  dig _xmpp-server._tcp.$domain -t srv +short
  echo ""
  echo "KERBEROS"
  echo "--------"
  dig _kerberos._tcp.$domain -t srv +short
  dig _kerberos._udp.$domain -t srv +short
  dig _kerberos-master._tcp.$domain -t srv +short
  dig _kpasswd._tcp.$domain -t srv +short
  echo ""
  echo "LDAP"
  echo "----"
  dig _ldap._tcp.$domain -t srv +short
  echo ""
  echo "Matrix"
  echo "------"
  dig _matrix._tcp.$domain -t srv +short
  echo ""
  echo "Email DMARC records"
  echo "-------------------"
  nslookup -type=txt _dmarc.$domain
  echo ""
  echo "NMAP results: nmap -T4 -p 53 --script dns-brute $domain"
  echo "------------"
  nmap -T4 -p 53 --script dns-brute $domain
  echo ""
  echo ""
  echo "SecurityTrails"
  echo "--------------"
  curl --request GET \
      --url https://api.securitytrails.com/v1/domain/$domain \
      --header 'APIKEY: --- PUT YOUR OWN API KEY HERE ---' \
      --header 'accept: application/json'
  echo ""
  echo ""
  echo "Shodan"
  echo "------"
  shodan domain $domain
  echo ""
  echo ""
  # The following checks for well known files aren't reliable all the time.
  # YMMV when collecting these details
  echo "Checking for .well-known files"
  echo "------------------------------"
  echo ""
  echo "robots.txt"
  echo "----------"
  if wget -q --method=HEAD https://$domain/robots.txt;
    then
      cat robots.txt
      rm robots.txt
    else
      echo "robots.txt does not exist."
  fi
  echo ""
  echo ".well-known/security.txt"
  echo "-------------------------"
  if wget -q --method=HEAD https://$domain/.well-known/security.txt;
    then
      cat security.txt
      rm security.txt
    else
      echo ".well-known/security.txt does not exist."
  fi
  echo ""
  echo ""
}

get_ip_addresses () {
  echo ""
  echo "IP Addresses of Interest"
  echo "------------------------"
  grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' $output | uniq | sort
  echo ""
  echo "--- EOF ---"
}

if [ $2 ];
  then
    echo "Collecting results for $domain"
    get_dns_records > $output
    get_ip_addresses >> $output
  else
    echo "Collecting results for $domain"
    output=$domain.txt
    get_dns_records > $output
    get_ip_addresses >> $output
    cat $output
    rm $output
fi
